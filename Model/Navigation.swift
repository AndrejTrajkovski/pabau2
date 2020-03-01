public enum Navigation {
	case login([LoginNavScreen])
	case tabBar(TabBarNavigation)
	public var login: [LoginNavScreen]? {
		get {
			guard case let .login(value) = self else { return nil }
			return value
		}
		set {
			guard case .login = self, let newValue = newValue else { return }
			self = .login(newValue)
		}
	}
	public var tabBar: TabBarNavigation? {
		get {
			guard case let .tabBar(value) = self else { return nil }
			return value
		}
		set {
			guard case .tabBar = self, let newValue = newValue else { return }
			self = .tabBar(newValue)
		}
	}
}

public enum LoginNavScreen {
	case walkthroughScreen
	case signInScreen
	case forgotPassScreen
	case checkEmailScreen
	case resetPassScreen
	case passChangedScreen
}

public enum TabBarNavigation {
	case journey
	case calendar
}
