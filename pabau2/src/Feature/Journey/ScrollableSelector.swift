import SwiftUI
import Model

struct ScrollableSelector: View {
	let steps: [Step]
	@Binding var selection: Step
	
	func text(for index: Step) -> some View {
		Group {
			if index == selection {
				VStack {
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(.blue)
					Text(index.stepType.rawValue).font(.medium10)
				}
				.onTapGesture {
					self.selection = index
				}
			} else {
				VStack {
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(.gray)
					Text(index.stepType.rawValue).font(.medium10)
				}
				.onTapGesture {
					self.selection = index
				}
			}
		}
	}
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(alignment: .center, spacing: 12) {
				ForEach(0 ..< steps.count) {
					self.text(for: self.steps[$0])
				}
			}
			.padding([.leading, .trailing], 4)
		}
		.frame(height: 36)
			.cornerRadius(8)
	}
}
