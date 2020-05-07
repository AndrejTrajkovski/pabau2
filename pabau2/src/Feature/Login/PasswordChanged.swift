import SwiftUI
import ComposableArchitecture
import Util
import Model

public let passChangedReducer = Reducer<[LoginNavScreen], PassChangedAction, LoginEnvironment> { state, action, _ in
	switch action {
	case .signInTapped:
		state.removeAll(where: { $0 == .passChangedScreen })
		state.removeAll(where: { $0 == .resetPassScreen })
		state.removeAll(where: { $0 == .checkEmailScreen })
		state.removeAll(where: { $0 == .forgotPassScreen })
		return .none
	}
}

public enum PassChangedAction: Equatable {
	case signInTapped
}

public struct PasswordChanged: View {
	let store: Store<[LoginNavScreen], PassChangedAction>
	let content = WalkthroughContentContent(title: Texts.passwordChanged,
																					description: Texts.passwordChangedDesc,
																					imageTitle: "illu-password-changed")
	public var body: some View {
		WithViewStore(self.store) { viewStore in
			WalkthroughContentAndButton(content: self.content,
																	btnTitle: Texts.signIn,
																	btnAction: { viewStore.send(.signInTapped) })
				.navigationBarBackButtonHidden(true)
		}
	}
}
