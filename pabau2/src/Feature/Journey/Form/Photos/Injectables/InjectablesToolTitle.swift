import SwiftUI
import Util

struct InjectablesToolTitle: View {
	let title: String
	let description: String
	let color: Color

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				Circle()
					.fill(color)
					.frame(width: 10, height: 10)
				Text(title).font(.medium18)
			}
			Text(description).font(.regular16)
		}
	}
}
