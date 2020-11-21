import SwiftUI

public struct LabelAndTextField: View {
	let labelTxt: String
	let valueText: String
	public init(_ labelTxt: String,
				_ valueText: String) {
		self.labelTxt = labelTxt
		self.valueText = valueText
	}
	public var body: some View {
		LabelAndLowerContent(labelTxt) {
			Text(self.valueText)
				.foregroundColor(Color.textFieldAndTextLabel)
				.font(.semibold15)
		}
	}
}

public struct LabelAndLowerContent<Content: View>: View {
	public init(_ labelTxt: String,
				@ViewBuilder _ lowerContent: @escaping () -> Content) {
		self.labelTxt = labelTxt
		self.lowerContent = lowerContent
	}
	let labelTxt: String
	let lowerContent: () -> Content
	public var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(labelTxt)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
				.font(.bold12)
			lowerContent()
			Divider().foregroundColor(.textFieldBottomLine)
		}
	}
}
