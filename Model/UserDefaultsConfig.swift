struct UserDefaultsConfig {
	@UserDefault("has_seen_app_introduction", defaultValue: false)
	static var hasSeenAppIntroduction: Bool!
	
	@UserDefault("logged_in_user", defaultValue: nil)
	static var loggedInUser: User?
}
