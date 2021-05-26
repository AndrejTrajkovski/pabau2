import SwiftUI

public struct TitleAndValueLabel: View {

	let labelTxt: String
	let valueText: String
    var textColor: Color?
	@Binding var error: String?
	
	public init(
        _ labelTxt: String,
		_ valueText: String,
        _ textColor: Color? = nil,
		_ error: Binding<String?>
    ) {
		self.labelTxt = labelTxt
		self.valueText = valueText
        self.textColor = textColor
        self._error = error
	}
	public var body: some View {
		TitleAndLowerContent(labelTxt, $error) {
			Text(self.valueText)
				.foregroundColor(textColor ?? Color.textFieldAndTextLabel)
				.font(.semibold15)
		}
	}
}

public struct TitleAndLowerContent<Content: View>: View {
	public init(
        _ labelTxt: String,
        _ error: Binding<String?>,
        @ViewBuilder _ lowerContent: @escaping () -> Content
    ) {
		self.labelTxt = labelTxt
		self.lowerContent = lowerContent
		self._error = error
	}

	let labelTxt: String
	let lowerContent: () -> Content
    @Binding var error: String?

	public var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(labelTxt)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
				.font(.semibold12)
			lowerContent()
            Divider()
				.background(error == nil ? Color.textFieldBottomLine : Color.red)
            Text(error ?? " ")
                .font(.bold13)
                .foregroundColor(.red)
		}
	}
}
