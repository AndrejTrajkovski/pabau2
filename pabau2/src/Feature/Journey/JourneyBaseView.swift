import SwiftUI
import Model

public struct JourneyBaseView<Content: View>: View {
	let journey: Journey
	let content: Content
	init(journey: Journey,
			 @ViewBuilder content: () -> Content) {
		self.journey = journey
		self.content = content()
	}
	public var body: some View {
		VStack(spacing: 8) {
			makeProfileView(journey: journey)
				.padding()
			content
		}
	}
}
