import SwiftUI
import ComposableArchitecture

public struct ResetPasswordState {
	var navigation: Navigation
}

public enum ResetPasswordAction {
	case backBtnTapped
	case changePassTapped
}

public func resetPassReducer(state: inout ResetPasswordState, action: ResetPasswordAction) -> [Effect<ResetPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation = .login(.signIn(.forgotPass(.forgotPass)))
		return []
	case .changePassTapped:
		return []
	}
}

struct ResetPassword: View {
	var store: Store<ResetPasswordState, ResetPasswordAction>
	@State var code: String = ""
	@State var newPass: String = ""
	@State var confirmPass: String = ""

	var body: some View {
		VStack {
			VStack(alignment: .leading, spacing: 25) {
				VStack(alignment: .leading, spacing: 36) {
					Text(Texts.forgotPass)
						.foregroundColor(.blackTwo)
						.font(.largeTitle)
						.frame(width: 157)
					Text(Texts.forgotPassDescription)
						.foregroundColor(.grey155)
						.font(.paragraph)
					TextAndTextView(title: Texts.resetCode.uppercased(), value: $code)
					TextAndTextView(title: Texts.newPass.uppercased(), value: $newPass)
					TextAndTextView(title: Texts.confirmPass.uppercased(), value: $confirmPass)
				}.frame(maxWidth: 319)
				BigButton(text: Texts.changePass) {
					self.store.send(.changePassTapped)
				}
			}
			.frame(minWidth: 280, maxWidth: 495)
			.fixedSize(horizontal: false, vertical: true)
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
			Spacer()
		}
	}
}
