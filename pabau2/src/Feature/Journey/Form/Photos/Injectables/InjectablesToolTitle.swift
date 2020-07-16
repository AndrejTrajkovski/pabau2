import SwiftUI
import Util

struct InjectablesToolTitle: View {
	let title: String
	let description: String
	let color: Color

	var body: some View {
		HStack {
			Circle()
				.fill(color)
				.frame(width: 15, height: 15)
			VStack(alignment: .leading, spacing: 8) {
				Text(title).font(.medium25)
				Text(description).font(.regular16)
			}
		}
	}
}
