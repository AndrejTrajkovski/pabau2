import SwiftUI
#if !os(macOS)

public struct PatientDetailsField<Content: View>: View {
	public init(_ title: String,
				_ placeholder: String = "",
				_ validation: String? = nil,
				_ content: @escaping () -> Content) {
		self.title = title
		self.placeholder = placeholder
		self.validation = validation
		self.content = content
	}
	
	let title: String
	let placeholder: String
	let validation: String?
	let content: () -> Content
	
	public var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(title.uppercased())
				.font(.bold10)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
			
			VStack(spacing: 0) {
				content()
					.frame(height: 36)
					.font(.medium15)
				HorizontalLine(color: .black)
					.frame(maxWidth: .infinity)
			}
				.padding(.bottom, 1.0)

			
			if validation != nil {
				ValidationText(title: validation!)
			}
		}
	}
}

public struct TextAndTextField: View {
	public init(_ title: String,
				_ bindingValue: Binding<String>,
				_ placeholder: String = "",
				_ validation: String? = nil) {
		self.title = title
		self.placeholder = placeholder
		self._value = bindingValue
		self.validation = validation
	}
	
	let title: String
	let placeholder: String
	@Binding var value: String
	let validation: String?
	
	public var body: some View {
		PatientDetailsField(title,
							placeholder,
							validation) {
			TextField(placeholder, text: $value)
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
#endif
