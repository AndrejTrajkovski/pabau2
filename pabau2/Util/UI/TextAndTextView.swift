import SwiftUI

struct TextAndTextView: View {
	let title: String
	let placeholder: String
	@Binding var value: String
	var body: some View {
		VStack(alignment: .leading) {
			Text(title)
				.font(.textInTextAndTextField)
				.foregroundColor(.textFieldAndTextLabel)
			TextFieldWithBottomLine(placeholder: placeholder, text: $value)
				.font(.textFieldInTextAndTextField)
		}
	}
}
