import SwiftUI
import UtilPackage

struct JourneyTransitionView<Content: View>: View {
	let title: String
	let description: String
	let content: () -> Content

	var body: some View {
		VStack(spacing: 24) {
			content()
			Text(title).foregroundColor(.white).font(.regular24)
			Text(description).foregroundColor(.checkInSubtitle).font(.regular16)
		}
	}
}
