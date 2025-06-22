import Foundation
import AVFoundation

/// Generic function to fade in audio
/// - Parameters:
///   - player: The AVAudioPlayer to fade in
///   - targetVolume: Target volume (0.0 to 1.0)
///   - duration: Duration of fade in seconds
func fadeInAudio(player: AVAudioPlayer?, targetVolume: Float, duration: TimeInterval) {
    guard let player = player else { return }
    
    let steps = 20
    let stepDuration = duration / Double(steps)
    let volumeStep = targetVolume / Float(steps)
    
    for stepIndex in 0...steps {
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(stepIndex)) {
            player.volume = volumeStep * Float(stepIndex)
        }
    }
}

/// Generic function to fade out audio
/// - Parameters:
///   - player: The AVAudioPlayer to fade out
///   - duration: Duration of fade out in seconds
///   - completion: Completion block called when fade out is finished
func fadeOutAudio(player: AVAudioPlayer?, duration: TimeInterval, completion: @escaping () -> Void) {
    guard let player = player else {
        completion()
        return
    }
    
    let steps = 20
    let stepDuration = duration / Double(steps)
    let currentVolume = player.volume
    let volumeStep = currentVolume / Float(steps)
    
    for stepIndex in 0...steps {
        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(stepIndex)) {
            player.volume = currentVolume - (volumeStep * Float(stepIndex))
            
            if stepIndex == steps {
                player.stop()
                completion()
            }
        }
    }
}
