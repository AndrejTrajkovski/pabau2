import SwiftUI
import Model

public struct ChoosePathway: View {
	let journey: Journey
	public var body: some View {
		VStack(spacing: 8) {
			view(journey: journey)
		}
	}
}
