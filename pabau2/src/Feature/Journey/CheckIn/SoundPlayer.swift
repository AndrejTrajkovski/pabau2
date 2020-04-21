import Combine
import AVFoundation

class Player: ObservableObject {

	var sound: AVAudioPlayer!

	let willChange = PassthroughSubject<Player, Never>()

	var isPlaying: Bool = false {
		willSet {
			willChange.send(self)
		}
	}

	func playSoundAndVibrate() {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
		if let path = Bundle.main.path(forResource: "checkIn", ofType: "mp4") {
			do {
				sound = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
				print("Playing sounddd")
				sound.play()
			} catch {
				print( "Could not find file")
			}
		}
	}
}
