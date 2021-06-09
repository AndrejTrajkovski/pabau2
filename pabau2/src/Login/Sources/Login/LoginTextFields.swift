import SwiftUI
import Util

struct LoginTextFields: View {
    
    @Binding var email: String
    @Binding var password: String
    let emailValidation: String
    let passwordValidation: String
    let onForgotPass: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            TextAndTextField(
                Texts.emailAddress.uppercased(),
                $email,
                "",
                emailValidation
            )
            HStack(spacing: 0) {
                TextAndTextField(
                    Texts.password.uppercased(),
                    $password,
                    "",
                    passwordValidation
                )
                Button.init(Texts.forgotPass) {
                    self.onForgotPass()
                }
                .font(.bold13)
                .foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
            }.padding(.top, 10)
        }
    }
}
