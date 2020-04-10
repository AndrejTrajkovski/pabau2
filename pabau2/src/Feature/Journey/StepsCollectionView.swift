import CollectionUI
import SwiftUI
import Model

struct StepsCollectionView: View {
	init (steps: [Step], selectionId: Binding<Int>) {
		self._selection = selectionId
		self.stepVms = steps.map { Self.stepVM(step: $0, selection: selectionId.wrappedValue)}
	}
	let stepVms: [StepVM]
	@Binding var selection: Int
	
	struct StepVM {
		let id: Int
		let isSelected: Bool
		let title: String
	}
	
	static func stepVM(step: Step, selection: Int) -> StepVM {
		return StepVM(id: step.id, isSelected: step.id == selection, title: step.stepType.title)
	}
	
	func stepView(for viewModel: StepVM) -> some View {
		Group {
			if viewModel.isSelected {
				VStack {
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(.blue)
						.frame(width: 30, height: 30)
					Text(viewModel.title)
						.font(.medium10)
						.foregroundColor(Color(hex: "909090"))
				}.onTapGesture {
					self.selection = viewModel.id
				}
			} else {
				VStack {
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(.gray)
						.frame(width: 30, height: 30)
					Text(viewModel.title)
						.font(.medium10)
						.foregroundColor(Color(hex: "909090"))
				}
				.onTapGesture {
					self.selection = viewModel.id
				}
			}
		}
	}
	
//	func step(for index: Step) -> some View {
//		Group {
//			if index == selection {
//				VStack {
//					Image(systemName: "checkmark.circle.fill")
//						.foregroundColor(.blue)
//						.frame(width: 30, height: 30)
//					Text(index.stepType.title)
//						.font(.medium10)
//						.foregroundColor(Color(hex: "909090"))
//				}.onTapGesture {
//					self.selection = index
//				}
//			} else {
//				VStack {
//					Image(systemName: "checkmark.circle.fill")
//						.foregroundColor(.gray)
//						.frame(width: 30, height: 30)
//					Text(index.stepType.title)
//						.font(.medium10)
//						.foregroundColor(Color(hex: "909090"))
//				}
//				.onTapGesture {
//					self.selection = index
//				}
//			}
//		}
//	}

	var body: some View {
		CollectionView(stepVms, id: \.id) {
			stepView(for: $0)
		}
		.axis(.horizontal)
		.indicators(false)
		.groupSize(.init(widthDimension: .fractionalWidth(1/CGFloat(stepVms.count)),
										 heightDimension: .fractionalHeight(0.1)))
		.itemSize(.init(widthDimension: .absolute(80),
										heightDimension: .absolute(50)))
			.layout({ (layout) in
				layout.interGroupSpacing = 0
			})
	}
}
