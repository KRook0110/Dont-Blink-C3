import SwiftUI

struct LandmarkOverlay: View {
    let landmarks: [CGPoint]
    let leftEye: [CGPoint]
    let rightEye: [CGPoint]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // All landmarks (dengan opacity lebih rendah)
                ForEach(landmarks.indices, id: \ .self) { i in
                    let pt = landmarks[i]
                    Circle()
                        .fill(Color.yellow.opacity(0.6))
                        .frame(width: 4, height: 4)
                        .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                }
                // Left eye (mata kiri - lebih menonjol)
                ForEach(leftEye.indices, id: \ .self) { i in
                    let pt = leftEye[i]
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 10, height: 10)
                                .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                        )
                }
                // Right eye (mata kanan - lebih menonjol)
                ForEach(rightEye.indices, id: \ .self) { i in
                    let pt = rightEye[i]
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 10, height: 10)
                                .position(x: pt.x * geo.size.width, y: (1 - pt.y) * geo.size.height)
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

