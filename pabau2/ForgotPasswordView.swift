import SwiftUI
import ComposableArchitecture

public enum ForgotPassViewAction {
	case forgotPass(ForgotPasswordAction)
	case resetPass(ResetPasswordAction)
	var forgotPass: ForgotPasswordAction? {
		get {
			guard case let .forgotPass(value) = self else { return nil }
			return value
		}
		set {
			guard case .forgotPass = self, let newValue = newValue else { return }
			self = .forgotPass(newValue)
		}
	}
	var resetPass: ResetPasswordAction? {
		get {
			guard case let .resetPass(value) = self else { return nil }
			return value
		}
		set {
			guard case .resetPass = self, let newValue = newValue else { return }
			self = .resetPass(newValue)
		}
	}
}

public struct ForgotPassViewState {
	var email: String
	var navigation: Navigation
	var forgotPass: ForgotPassState {
		get { return ForgotPassState(email: email, navigation: navigation)}
		set {
			self.navigation = newValue.navigation
			self.email = newValue.email
		}
	}
	var resetPass: ResetPasswordState {
		get { return ResetPasswordState(navigation: navigation)}
		set { self.navigation = newValue.navigation }
	}
}

public struct ForgotPassState {
	var email: String
	var navigation: Navigation
}

let forgotPassViewReducer = combine(
	pullback(forgotPasswordReducer, value: \ForgotPassViewState.forgotPass, action: \ForgotPassViewAction.forgotPass),
	pullback(resetPassReducer, value: \ForgotPassViewState.resetPass, action: \ForgotPassViewAction.resetPass)
)

public func forgotPasswordReducer(state: inout ForgotPassState,
																	action: ForgotPasswordAction) -> [Effect<ForgotPasswordAction>] {
	switch action {
	case .backBtnTapped:
		state.navigation = .login(.signIn(.signIn))
		return []
	case .sendRequest:
		state.navigation = .login(.signIn(.forgotPass(.resetPass)))
		return []
	}
}

public enum ForgotPasswordAction {
	case backBtnTapped
	case sendRequest
}

struct ForgotPassword: View {
	var store: Store<ForgotPassState, ForgotPasswordAction>
	@State private var email: String = ""
	init(_ store: Store<ForgotPassState, ForgotPasswordAction>) {
		self.store = store
		self.email = store.value.email
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 25) {
			VStack(alignment: .leading, spacing: 36) {
				Text(Texts.forgotPass)
					.foregroundColor(.blackTwo)
					.font(.largeTitle)
					.frame(width: 157)
				Text(Texts.forgotPassDescription)
					.foregroundColor(.grey155)
					.font(.paragraph)
				TextAndTextView(title: Texts.emailAddress.uppercased(), value: $email)
			}.frame(maxWidth: 319)
			BigButton(text: Texts.sendRequest) {
				self.store.send(.sendRequest)
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
	}
}

struct ForgotPasswordView: View {
	var store: Store<ForgotPassViewState, ForgotPassViewAction>
	@State private var email: String = ""
	init(_ store: Store<ForgotPassViewState, ForgotPassViewAction>) {
		self.store = store
		self.email = store.value.email
	}
	@Environment(\.presentationMode) var presentationMode
	var body: some View {
		VStack(alignment: .leading, spacing: 36) {
			ForgotPassword(self.store.view(value: { $0.forgotPass }, action: { .forgotPass($0)}))
			NavigationLink(destination:
				ResetPassword(store: self.store.view(value: { $0.resetPass },
																						 action: { .resetPass($0)})),
										 isActive: .constant(self.store.value.navigation.login?.signIn?.forgotPass == .resetPass)){
				EmptyView()
			}.hidden()
			Spacer()
		}
	}
}
