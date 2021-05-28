import Foundation
import ComposableArchitecture
import AVFoundation

private let queue = DispatchQueue(label: "Audio Dispatch Queue")

public struct AudioPlayer: AudioPlayerProtocol {
	
	let sound = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "checkIn", ofType: "mp4")!))
	
	public init () {}
	
	public func playCheckInSound() -> Effect<Never, Never> {
		
		return .fireAndForget {
//			queue.async {
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
				sound.play()
//			}
		}
	}
}
