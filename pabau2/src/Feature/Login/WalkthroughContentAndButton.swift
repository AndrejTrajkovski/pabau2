import SwiftUI
import Util

public struct WalkthroughContentAndButton: View {
	let content: WalkthroughContentContent
	let btnTitle: String
	let btnAction: () -> Void
	public var body: some View {
		VStack(spacing: 50) {
			WalkthroughContentView.init(state: content)
			BigButton(text: self.btnTitle) {
				self.btnAction()
			}
		}
	}
}
