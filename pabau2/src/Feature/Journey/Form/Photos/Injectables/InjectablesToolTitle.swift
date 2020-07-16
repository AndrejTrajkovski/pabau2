import SwiftUI
import Util

struct InjectablesToolTitle: View {
	let title: String
	let description: String
	let color: Color

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Circle()
					.fill(color)
					.frame(width: 15, height: 15)
				Text(title).font(.medium25)
			}
			Text(description).font(.regular16)
		}
	}
}
