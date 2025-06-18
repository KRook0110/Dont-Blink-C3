import SwiftUI
import AVFoundation
import Vision
import CoreML

struct EyePrediction: Identifiable, Equatable {
    let id = UUID()
    let side: String
    let label: String
    let confidence: Float
    let image: NSImage
}

class EyeBlinkDetectorML: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isProcessingFrame = true
    @Published var inferenceResult: String = ""
    @Published var eyePredictions: [EyePrediction] = []
    
    // Variables untuk kompatibilitas dengan EyeBlinkDetector
    @Published var isLeftBlink: Bool = false
    @Published var isRightBlink: Bool = false
    @Published var faceCount: Int = 0
    
    private let mlModel: VNCoreMLModel
    private let confidenceThreshold: Float = 0.8
    
    // Frame limiting for performance
    private var frameCounter = 0
    private let processEveryNFrames = 2 // Process every 2nd frame (30fps -> 15fps)

    override init() {
        do {
            let config = MLModelConfiguration()
            let model = try mrl11s25epochs(configuration: config)
            mlModel = try VNCoreMLModel(for: model.model)
        } catch {
            fatalError("Could not load model: \(error)")
        }
        super.init()
        requestCameraAccess()
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                }
            }
        default:
            print("Camera access denied or restricted.")
        }
    }

    private func setupCamera() {
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else { return }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue", qos: .userInitiated))
        guard session.canAddOutput(output) else { return }

        session.addInput(input)
        session.addOutput(output)
        session.startRunning()
    }
}

extension EyeBlinkDetectorML: AVCaptureVideoDataOutputSampleBufferDelegate {

    func showNoFaceDetectedAlert() {
        let alert = NSAlert()
        alert.messageText = "No face detected"
        alert.informativeText = "Please make sure your face is visible to the camera."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
        DispatchQueue.main.async {
            self.isProcessingFrame = true
        }
    }

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isProcessingFrame else { return }
        
        // Frame limiting - process every Nth frame to reduce CPU usage
        frameCounter += 1
        guard frameCounter % processEveryNFrames == 0 else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest { request, _ in
            guard let observations = request.results as? [VNFaceObservation], !observations.isEmpty else {
                DispatchQueue.main.async {
                    self.inferenceResult = ""
                    self.eyePredictions = []
                    self.faceCount = 0
                    self.isLeftBlink = false
                    self.isRightBlink = false

                    self.isProcessingFrame = false
                    self.showNoFaceDetectedAlert()
                }
                return
            }

            // Filter wajah yang terlalu kecil (threshold minimum area 0.01)
            let validFaces = observations.filter { face in
                let area = face.boundingBox.width * face.boundingBox.height
                return area > 0.01  // Hanya proses wajah dengan area > 1% dari frame
            }
            
            guard !validFaces.isEmpty else {
                DispatchQueue.main.async {
                    self.inferenceResult = ""
                    self.eyePredictions = []
                    self.faceCount = 0
                    self.isProcessingFrame = false
                    self.showNoFaceDetectedAlert()
                }
                return
            }
            
            // Update faceCount
            DispatchQueue.main.async {
                self.faceCount = validFaces.count
            }
            
            // Pilih wajah dengan bounding box terbesar dari wajah yang valid
            let largestFace = validFaces.max { face1, face2 in
                let area1 = face1.boundingBox.width * face1.boundingBox.height
                let area2 = face2.boundingBox.width * face2.boundingBox.height
                return area1 < area2
            }
            
            guard let face = largestFace,
                  let leftEye = face.landmarks?.leftEye,
                  let rightEye = face.landmarks?.rightEye else {
                DispatchQueue.main.async {
                    self.inferenceResult = ""
                    self.eyePredictions = []
                    self.isProcessingFrame = false
                    self.showNoFaceDetectedAlert()
                }
                return
            }

        let leftRect = self.cropEye(eye: leftEye, face: face, pixelBuffer: pixelBuffer)
        let rightRect = self.cropEye(eye: rightEye, face: face, pixelBuffer: pixelBuffer)

        let leftImage = self.convertCropToNSImage(pixelBuffer: pixelBuffer, rect: leftRect)
        let rightImage = self.convertCropToNSImage(pixelBuffer: pixelBuffer, rect: rightRect)

        // Create CIImages directly for prediction
        let leftCIImage = self.createProcessedImage(pixelBuffer: pixelBuffer, rect: leftRect)
        let rightCIImage = self.createProcessedImage(pixelBuffer: pixelBuffer, rect: rightRect)

        let results = self.predictEyes(images: [leftCIImage, rightCIImage])
        let leftResult = results[0]
        let rightResult = results[1]



        DispatchQueue.main.async {
            let leftIsValid = leftResult.1 >= self.confidenceThreshold
            let rightIsValid = rightResult.1 >= self.confidenceThreshold

            
            self.eyePredictions = [
                EyePrediction(side: "Right", label: leftIsValid ? leftResult.0 : "", confidence: leftResult.1, image: leftImage),
                EyePrediction(side: "Left", label: rightIsValid ? rightResult.0 : "", confidence: rightResult.1, image: rightImage)
            ]
            let leftIsClosed = leftIsValid && (leftResult.0 == "close" || leftResult.0 == "close")
            let rightIsClosed = rightIsValid && (rightResult.0 == "close" || rightResult.0 == "close")

            // Update isLeftBlink dan isRightBlink
            self.isLeftBlink = leftIsClosed
            self.isRightBlink = rightIsClosed

            if leftIsClosed || rightIsClosed {
                self.inferenceResult = "Close"
            } else if leftIsValid || rightIsValid {
                self.inferenceResult = "Open"
            } else {
                self.inferenceResult = "Open"
            }
            
        }
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    private func predictEyes(images: [CIImage]) -> [(String, Float)] {
        var results: [(String, Float)] = []

        for ciImage in images {
            let request = VNCoreMLRequest(model: mlModel)
            request.imageCropAndScaleOption = .scaleFit
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            
            do {
                try handler.perform([request])
                
                if let observations = request.results as? [VNClassificationObservation],
                   let topResult = observations.first {
                    results.append((topResult.identifier, topResult.confidence))
                } else {
                    results.append(("-", 0.0))
                }
            } catch {
                results.append(("-", 0.0))
            }
        }

        return results
    }

    private func cropEye(eye: VNFaceLandmarkRegion2D, face: VNFaceObservation, pixelBuffer: CVPixelBuffer) -> CGRect {
        let w = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let h = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let faceRect = CGRect(
            x: face.boundingBox.origin.x * w,
            y: face.boundingBox.origin.y * h,
            width: face.boundingBox.width * w,
            height: face.boundingBox.height * h
        )

        let xs = eye.normalizedPoints.map { $0.x }
        let ys = eye.normalizedPoints.map { $0.y }
        guard let minX = xs.min(), let maxX = xs.max(),
              let minY = ys.min(), let maxY = ys.max() else { return .zero }

        // Calculate eye center for better cropping
        let centerX = faceRect.origin.x + ((minX + maxX) / 2) * faceRect.width
        let centerY = faceRect.origin.y + ((minY + maxY) / 2) * faceRect.height
        
        // Use larger padding to capture more context like in training data
        let eyeWidth = (maxX - minX) * faceRect.width
        let eyeHeight = (maxY - minY) * faceRect.height
        
        // Make it square and add padding similar to photo mode
        let cropSize = max(eyeWidth, eyeHeight) * 2.0 // Consistent padding for accuracy
        
        var rect = CGRect(
            x: centerX - cropSize / 2,
            y: centerY - cropSize / 2,
            width: cropSize,
            height: cropSize
        )
        
        // Ensure the crop is within image bounds
        rect = rect.intersection(CGRect(x: 0, y: 0, width: w, height: h))
        
        // Ensure minimum size
        if rect.width < 50 || rect.height < 50 {
            let minSize: CGFloat = 50
            rect = CGRect(
                x: max(0, centerX - minSize / 2),
                y: max(0, centerY - minSize / 2),
                width: min(minSize, w - max(0, centerX - minSize / 2)),
                height: min(minSize, h - max(0, centerY - minSize / 2))
            )
        }
        
        return rect
    }

    private func createProcessedImage(pixelBuffer: CVPixelBuffer, rect: CGRect) -> CIImage {
        let targetSize = CGSize(width: 640, height: 640)
        let scaleX = targetSize.width / rect.width
        let scaleY = targetSize.height / rect.height
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            .cropped(to: rect)
            .applyingFilter("CIPhotoEffectMono")
            .transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        return ciImage
    }
    


    private func convertCropToNSImage(pixelBuffer: CVPixelBuffer, rect: CGRect) -> NSImage {
        let processedImage = createProcessedImage(pixelBuffer: pixelBuffer, rect: rect)
        
        let rep = NSCIImageRep(ciImage: processedImage)
        let nsImage = NSImage(size: NSSize(width: 640, height: 640))
        nsImage.addRepresentation(rep)
        return nsImage
    }
}