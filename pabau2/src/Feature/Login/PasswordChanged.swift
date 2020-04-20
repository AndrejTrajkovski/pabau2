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
		return []
	}
}

public enum PassChangedAction: Equatable {
	case signInTapped
}

public struct PasswordChanged: View {
	let store: Store<[LoginNavScreen], PassChangedAction>
	@ObservedObject var viewStore: ViewStore<[LoginNavScreen], PassChangedAction>
	init (store: Store<[LoginNavScreen], PassChangedAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	let content = WalkthroughContentContent(title: Texts.passwordChanged,
																					description: Texts.passwordChangedDesc,
																					imageTitle: "illu-password-changed")
	public var body: some View {
		WalkthroughContentAndButton(content: content,
																btnTitle: Texts.signIn,
																btnAction: { self.viewStore.send(.signInTapped) })
		.navigationBarBackButtonHidden(true)
	}
}
