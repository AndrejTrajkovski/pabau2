import SwiftUI
import ComposableArchitecture

public struct ResetPasswordState {
	var navigation: Navigation
}

public enum ResetPasswordAction {
	case backBtnTapped
	case forgotPassTapped
}

public func resetPassReducer(state: inout ResetPasswordState, action: ResetPasswordAction) -> [Effect<ResetPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation.resetPass = false
		return []
	case .forgotPassTapped:
		return []
	}
}

struct ResetPassword: View {
	var store: Store<ResetPasswordState, ResetPasswordAction>
	var body: some View {
		EmptyView()
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading:
			Button(action: {
				self.store.send(.backBtnTapped)
			}, label: {
					Image(systemName: "chevron.left")
						.font(Font.title.weight(.semibold))
					Text("Back")
			})
		)
	}
}
