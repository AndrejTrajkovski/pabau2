import SwiftUI
import ComposableArchitecture

public func forgotPasswordReducer(state: inout String,
																	action: ForgotPasswordAction) -> [Effect<ForgotPasswordAction>] {
	switch action {
	case .backBtnTapped:
		return []
	case .sendRequest:
		return []
	}
}

public enum ForgotPasswordAction {
	case backBtnTapped
	case sendRequest
}

struct ForgotPasswordView: View {
	var store: Store<String, ForgotPasswordAction>
	@State private var email: String = ""
	init(_ store: Store<String, ForgotPasswordAction>) {
		self.store = store
		self.email = store.value
	}
	@Environment(\.presentationMode) var presentationMode
	var body: some View {
		VStack(alignment: .leading, spacing: 36) {
			Text(Texts.forgotPass)
				.foregroundColor(.blackTwo)
				.font(.largeTitle)
				.frame(width: 157)
			Text(Texts.forgotPassDescription)
				.foregroundColor(.grey155)
				.font(.paragraph)
				.frame(maxWidth: 319)
			TextAndTextView(title: Texts.emailAddress.uppercased(), value: $email)
			BigButton(text: Texts.sendRequest) {
				self.store.send(.sendRequest)
			}
		}
			.frame(minWidth: 280, maxWidth: 495, alignment: .center)
			.fixedSize(horizontal: false, vertical: true)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading:
				Button(action: {
					self.store.send(.backBtnTapped)
				}) {
						HStack {
								Image(systemName: "arrow.left.circle")
								Text("Go Back")
						}
		})
	}
}
