import SwiftUI

struct LandmarkOverlay: View {
    let landmarks: [CGPoint]
    let leftEye: [CGPoint]
    let rightEye: [CGPoint]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // All landmarks
                ForEach(landmarks.indices, id: \ .self) { i in
                    let pt = landmarks[i]
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 6, height: 6)
                        .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                }
                // Left eye
                ForEach(leftEye.indices, id: \ .self) { i in
                    let pt = leftEye[i]
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                }
                // Right eye
                ForEach(rightEye.indices, id: \ .self) { i in
                    let pt = rightEye[i]
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                }
            }
        }
        .allowsHitTesting(false)
    }
} 