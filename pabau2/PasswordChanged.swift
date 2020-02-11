import SwiftUI
import ComposableArchitecture

public func passChangedReducer(state: inout Navigation, action: PassChangedAction) -> [Effect<PassChangedAction>] {
	switch action {
	case .signInTapped:
		state.login?.remove(.passChangedScreen)
		state.login?.remove(.resetPassScreen)
		state.login?.remove(.checkEmailScreen)
		state.login?.remove(.forgotPassScreen)
		return []
	}
}

public enum PassChangedAction {
	case signInTapped
}

public struct PasswordChanged: View {
	@ObservedObject var store: Store<Navigation, PassChangedAction>
	let content = WalkthroughContentContent(title: Texts.passwordChanged,
																					description: Texts.passwordChangedDesc,
																					imageTitle: "illu-password-changed")
	public var body: some View {
		WalkthroughContentAndButton(content: content,
																btnTitle: Texts.signIn,
																btnAction: { self.store.send(.signInTapped) })
		.navigationBarBackButtonHidden(true)
	}
}
