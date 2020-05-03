import SwiftUI
import Util

struct JourneyTransitionView<Content: View>: View {
	let title: String
	let description: String
	let circleContent: () -> Content

	var body: some View {
		VStack(spacing: 24) {
			Circle()
				.overlay(
					ZStack {
						circleContent()
							.foregroundColor(.white)
						Circle()
							.stroke(Color.white, lineWidth: 3.0)
					}
			).foregroundColor(Color.clear)
				.frame(width: 214, height: 214)
			Text(title).foregroundColor(.white).font(.regular24)
			Text(description).foregroundColor(.checkInSubtitle).font(.regular16)
		}
	}
}
