import SwiftUI

struct ColorCircleRow: View {
	let title: String
	let subtitle: String
	let color: Color
	var body: some View {
		HStack {
			Circle()
				.fill(color)
				.frame(width: 22.0, height: 22.0)
			Text(title).font(.regular17)
			Spacer()
			Text(subtitle).font(.regular17)
		}
	}
}
