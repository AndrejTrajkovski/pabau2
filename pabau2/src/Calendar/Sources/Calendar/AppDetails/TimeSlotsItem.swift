import SwiftUI
import Util

struct TimeSlotsItem: View {
	let onTap: () -> Void
	let image: String
	let title: String
	var body: some View {
		Button (action: onTap) {
			VStack(spacing: 8) {
				Image(systemName: image)
					.font(.medium38)
					.foregroundColor(.blue)
				Text(title)
					.foregroundColor(.black)
					.font(.regular17)
			}
		}.frame(maxWidth: .infinity, minHeight: 100)
		.padding(16)
		.border(Color(hex: "979797", alpha: 0.12), width: 1)
	}
}
