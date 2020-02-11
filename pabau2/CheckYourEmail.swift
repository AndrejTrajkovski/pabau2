import SwiftUI
import ComposableArchitecture
import CasePaths

func checkEmailReducer(state: inout Navigation, action: CheckEmailAction) -> [Effect<CheckEmailAction>] {
	switch action {
	case .passChangedTapped:
		state.login?.insert(.resetPassScreen)
		return []
	case .backBtnTapped:
		state.login?.remove(.checkEmailScreen)
		return []
	}
}

enum CheckEmailAction {
	case backBtnTapped
	case passChangedTapped
}

struct CheckEmail: View {
	let content = WalkthroughContentContent(title: Texts.checkYourEmail,
																					description: Texts.checkEmailDesc,
																					imageTitle: "illu-check-email")
	var body: some View {
		WalkthroughContentView.init(state: content)
	}
}
