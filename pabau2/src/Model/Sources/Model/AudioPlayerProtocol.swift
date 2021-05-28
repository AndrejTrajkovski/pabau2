import ComposableArchitecture

public protocol AudioPlayerProtocol {
	func playCheckInSound() -> Effect<Never, Never>
}
