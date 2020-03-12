import SwiftUI

public struct TextAndTextView: View {
	public init(title: String, placeholder: String, bindingValue: Binding<String>, validation: String) {
		self.title = title
		self.placeholder = placeholder
		self._value = bindingValue
		self.validation = validation
	}

	let title: String
	let placeholder: String
	@Binding var value: String
	let validation: String
	public var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title)
				.font(.bold10)
				.foregroundColor(.textFieldAndTextLabel)
			TextFieldWithBottomLine(placeholder: placeholder, text: $value)
				.font(.medium15)
			ValidationText(title: validation)
		}
	}
}

struct ValidationText: View {
	let title: String
	var body: some View {
		Text(title)
			.foregroundColor(.validationFail)
			.font(.semibold12)
	}
}
