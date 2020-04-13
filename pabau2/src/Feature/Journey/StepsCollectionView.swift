import Util
import SwiftUI
import Model

struct StepsCollectionView: View {
	let stepVms: [StepVM]
	@Binding var selection: Int {
		didSet {
			print(selection)
		}
	}

	init (steps: [Step], selectionId: Binding<Int>) {
		self._selection = selectionId
		self.stepVms = steps.map { Self.stepVM(step: $0, selection: selectionId.wrappedValue)}
		self.stepVms.forEach {print("\($0.id) is selected: \($0.isSelected)")}
	}

	struct StepVM {
		let id: Int
		let isSelected: Bool
		let title: String
	}

	static func stepVM(step: Step, selection: Int) -> StepVM {
		StepVM(id: step.id,
					 isSelected: step.id == selection,
					 title: step.stepType.title)
	}

	func stepView(for viewModel: StepVM) -> some View {
		VStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(viewModel.isSelected ? .blue : .gray)
				.frame(width: 30, height: 30)
			Text(viewModel.title)
				.font(.medium10)
				.foregroundColor(Color(hex: "909090"))
		}.onTapGesture {
			self.selection = viewModel.id
		}
	}

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
