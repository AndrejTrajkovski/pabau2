public protocol UserDefaultsConfig {
	var hasSeenAppIntroduction: Bool! { get set}
	var loggedInUser: User? { get set }
}

public struct StandardUDConfig: UserDefaultsConfig {
	public init () {}
	
	@UserDefault("has_seen_app_introduction", defaultValue: false)
	public var hasSeenAppIntroduction: Bool!

	@UserDefault("logged_in_user", defaultValue: nil)
	public var loggedInUser: User?
}
