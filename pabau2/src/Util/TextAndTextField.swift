import SwiftUI

public struct TextAndTextField: View {
	public init(_ title: String,
							_ bindingValue: Binding<String>,
							_ placeholder: String = "",
							_ validation: String = "") {
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
			Text(title.uppercased())
				.font(.bold10)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
			TextFieldWithBottomLine(placeholder: placeholder, text: $value)
				.font(.medium15)
//			ValidationText(title: validation)
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
