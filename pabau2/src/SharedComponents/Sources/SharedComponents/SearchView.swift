import SwiftUI
import Combine

public struct SearchView: View {
    var placeholder: String

    @Binding var text: String

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .font(.regular20)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if text != "" {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color(.systemGray3))
                    .padding(3)
                    .onTapGesture {
						self.text = ""
                    }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.vertical, 10)
    }
}
