import SwiftUI
    
struct ContentView: View {
    @StateObject private var detector = EyeBlinkDetector()
    
    var body: some View {
        ZStack {
            CameraView(detector: detector)
                .overlay(
                    LandmarkOverlay(landmarks: detector.landmarks, leftEye: detector.leftEyePoints, rightEye: detector.rightEyePoints)
                )
            VStack(alignment: .leading, spacing: 8) {
                Text("Faces Detected: \(detector.faceCount)")
                    .foregroundColor(detector.faceCount > 1 ? .orange : .white)
                Text("Face Area: \(String(format: "%.3f", detector.selectedFaceArea))")
                    .font(.caption)
                Divider()
                Text("Left EAR: \(String(format: "%.2f", detector.leftEAR))")
                Text("Right EAR: \(String(format: "%.2f", detector.rightEAR))")
                Text("Left Eye: \(detector.isLeftBlink ? "CLOSE" : "OPEN")")
                    .foregroundColor(detector.isLeftBlink ? .red : .green)
                Text("Right Eye: \(detector.isRightBlink ? "CLOSE" : "OPEN")")
                    .foregroundColor(detector.isRightBlink ? .red : .green)
                Text("Status: \((detector.isLeftBlink && detector.isRightBlink) ? "CLOSE" : "OPEN")")
                    .font(.headline)
                    .foregroundColor((detector.isLeftBlink && detector.isRightBlink) ? .red : .green)
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
