import SwiftUI

public struct BigButton: View {
	public init (text: String, btnTapAction: @escaping () -> Void) {
		self.text = text
		self.buttonTapAction = btnTapAction
	}
	let text: String
	var buttonTapAction: () -> Void
	public var body: some View {
		Button(action: {
			self.buttonTapAction()
		}, label: {
			Text(text)
				.font(Font.system(size: 16.0, weight: .bold))
				.frame(minWidth: 0, maxWidth: .infinity)
		}).buttonStyle(BigButtonStyle())
			.cornerRadius(10)
	}
}

struct BigButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.foregroundColor(Color.white)
			.background(Color.accentColor)
	}
}
