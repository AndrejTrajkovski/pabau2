import SwiftUI

struct TextAndTextView: View {
	let title: String
	let placeholder: String = ""
	@Binding var value: String
	var body: some View {
		VStack(alignment: .leading) {
			Text(title)
			TextField.init(placeholder, text: $value)
		}
	}
}
