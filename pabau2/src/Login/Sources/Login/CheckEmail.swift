import SwiftUI
import ComposableArchitecture
import Util
import Model

public let checkEmailReducer = Reducer<[LoginNavScreen], CheckEmailAction, LoginEnvironment> { state, action, _ in
	switch action {
	case .resetPassTapped:
		state.append(.resetPassScreen)
		return .none
	case .backBtnTapped:
		state.removeAll(where: { $0 == .checkEmailScreen })
		return .none
	}
}

public enum CheckEmailAction: Equatable {
	case backBtnTapped
	case resetPassTapped
}

public struct CheckEmail: View {
	let store: Store<[LoginNavScreen], CheckEmailAction>
	@ObservedObject var viewStore: ViewStore<[LoginNavScreen], CheckEmailAction>
	
	let resetPassStore: Store<ResetPasswordState, ResetPasswordAction>
	let passChangedStore: Store<[LoginNavScreen], PassChangedAction>
	public init(store: Store<[LoginNavScreen], CheckEmailAction>,
				resetPassStore: Store<ResetPasswordState, ResetPasswordAction>,
				passChangedStore: Store<[LoginNavScreen], PassChangedAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
		self.resetPassStore = resetPassStore
		self.passChangedStore = passChangedStore
	}
	let content = WalkthroughContentContent(title: Texts.checkYourEmail,
											description: Texts.checkEmailDesc,
											imageTitle: "illu-check-email")
	public var body: some View {
		VStack {
			WalkthroughContentAndButton(content: content,
										btnTitle: Texts.resetPass,
										btnAction: { self.viewStore.send(.resetPassTapped) }
			).customBackButton { self.viewStore.send(.backBtnTapped) }
			NavigationLink.emptyHidden(
				self.viewStore.state.contains(.resetPassScreen),
				resetPassView)
		}
	}
	
	var resetPassView: ResetPassword {
		ResetPassword(store: resetPassStore,
					  passChangedStore: passChangedStore
		)
	}
}
