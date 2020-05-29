import SwiftUI

public struct PrimaryButton: View {
	public init (_ text: String,
							 isDisabled: Bool = false,
							 _ btnTapAction: @escaping () -> Void) {
		self.text = text
		self.isDisabled = isDisabled
		self.buttonTapAction = btnTapAction
	}

	let text: String
	var buttonTapAction: () -> Void
	var isDisabled: Bool

	public var body: some View {
		Button(action: buttonTapAction,
					 label: {
			Text(text)
				.font(Font.system(size: 16.0, weight: .bold))
				.frame(minWidth: 0, maxWidth: .infinity)
		}).buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
			.disabled(isDisabled)
			.shadow(color: isDisabled ? .clear : Color.bigBtnShadow1,
							radius: 4.0,
							y: 2)
			.cornerRadius(4)
	}
}

struct PrimaryButtonStyle: ButtonStyle {
	var isDisabled: Bool
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.foregroundColor(Color.white)
			.background(Color.accentColor)
	}
}
