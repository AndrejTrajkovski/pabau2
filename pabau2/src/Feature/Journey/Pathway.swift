import SwiftUI
import Model
struct ChoosePathway: View {
	let journey: Journey
	var body: some View {
		VStack {
			view(journey: journey)
		}
	}
}
