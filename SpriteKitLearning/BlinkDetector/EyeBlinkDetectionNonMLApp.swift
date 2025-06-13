//
//  EyeBlinkDetectionNonMLApp.swift
//  EyeBlinkDetectionNonML
//
//  Created by Ammar Sufyan on 11/06/25.
//

import AppKit
import SwiftUI
import SpriteKit
import Combine

//@main
//struct EyeBlinkDetectionNonMLApp: App {
//    @StateObject private var detector = EyeBlinkDetector()
//    @State private var scene: GameScene? = nil
//    @State private var info = "0"
//    
//    var body: some Scene {
//        WindowGroup {
//            ZStack {
//                Color.gray
//                    .edgesIgnoringSafeArea(.all)
//                
//                VStack(spacing: 0) {
//                    Text("Score: \(info)")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                    
//                    if let scene = scene {
//                        SpriteView(scene: scene)
//                            .frame(minWidth: 500, minHeight: 500)
//                            .onReceive(scene.infoSender) { value in
//                                info = "\(value)"
//                            }
//                    }
//                }
//                
////                ContentView()
////                    .frame(width: 200, height: 150)
//            }
//            .onAppear {
//                if scene == nil {
//                    scene = GameScene(size: CGSize(width: 500, height: 500), detector: detector)
//                }
//            }
//        }
//    }
//}
