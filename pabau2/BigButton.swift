import SwiftUI

struct BigButton: View {
	let text: String
	var buttonTapAction: () -> Void
	var body: some View {
		Button(action: {
			self.buttonTapAction()
		}, label: {
			Text(text)
				.font(Font.system(size: 16.0, weight: .bold))
				.frame(minWidth: 0, maxWidth: .infinity)
		}).buttonStyle(BigButtonStyle())
			.cornerRadius(10)
			.frame(minWidth: 304, maxWidth: 495)
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
