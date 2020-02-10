import SwiftUI

struct CheckYourEmail: View {
	let content = WalkthroughContentContent(title: Texts.checkYourEmail,
																					description: Texts.checkEmailDesc,
																					imageTitle: "illu-check-email")
	var body: some View {
		WalkthroughContentView.init(state: content)
	}
}
