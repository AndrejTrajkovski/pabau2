import SwiftUI

struct TextAndTextView: View {
	let title: String
	let placeholder: String
	@Binding var value: String
	let validation: String
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			VStack(alignment: .leading) {
				Text(title)
					.font(.textInTextAndTextField)
					.foregroundColor(.textFieldAndTextLabel)
				TextFieldWithBottomLine(placeholder: placeholder, text: $value)
					.font(.textFieldInTextAndTextField)
			}
			ValidationText(title: validation)
		}
	}
}
