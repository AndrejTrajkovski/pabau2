import SwiftUI

struct PasswordChanged: View {
	let content = WalkthroughContentContent(title: Texts.passwordChanged,
																					description: Texts.passwordChangedDesc,
																					imageTitle: "illu-password-changed")
	var body: some View {
		WalkthroughContentView.init(state: content)
	}
}
