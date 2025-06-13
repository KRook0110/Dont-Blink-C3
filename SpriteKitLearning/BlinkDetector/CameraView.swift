import SwiftUI
import AVFoundation

struct CameraView: NSViewRepresentable {
    @ObservedObject var detector: EyeBlinkDetector
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: detector.getSession())
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer = CALayer()
        view.layer?.addSublayer(previewLayer)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let previewLayer = nsView.layer?.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = nsView.bounds
        }
    }
} 