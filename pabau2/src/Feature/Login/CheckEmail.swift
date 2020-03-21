import SwiftUI
import ComposableArchitecture
import Util
import Model

public func checkEmailReducer(state: inout Navigation, action: CheckEmailAction, environment: LoginEnvironment) -> [Effect<CheckEmailAction>] {
	switch action {
	case .resetPassTapped:
		state.login?.append(.resetPassScreen)
		return []
	case .backBtnTapped:
		state.login?.removeAll(where: { $0 == .checkEmailScreen })
		return []
	}
}

public enum CheckEmailAction: Equatable {
	case backBtnTapped
	case resetPassTapped
}

public struct CheckEmail: View {
	let resetPassStore: Store<ResetPasswordState, ResetPasswordAction>
	let passChangedStore: Store<Navigation, PassChangedAction>
	@ObservedObject var store: Store<Navigation, CheckEmailAction>
	let content = WalkthroughContentContent(title: Texts.checkYourEmail,
																					description: Texts.checkEmailDesc,
																					imageTitle: "illu-check-email")
	public var body: some View {
		VStack {
			WalkthroughContentAndButton(content: content,
																	btnTitle: Texts.resetPass,
																	btnAction: { self.store.send(.resetPassTapped) }
			).customBackButton { self.store.send(.backBtnTapped) }
		NavigationLink.emptyHidden(
			self.store.value.login?.contains(.resetPassScreen) ?? false,
			resetPassView)
		}
	}
	
	var resetPassView: ResetPassword {
		ResetPassword(passChangedStore: passChangedStore,
									store: resetPassStore)
	}
}
