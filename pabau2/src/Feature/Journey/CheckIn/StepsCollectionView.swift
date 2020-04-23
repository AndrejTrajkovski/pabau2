import Util
import SwiftUI
import Model

struct StepsCollectionView: View {
	let stepVms: [StepVM]
	let selectedId: Int
	let didSelect: (Int) -> Void

	init (steps: [Step], selectedId: Int, didSelect: @escaping (Int) -> Void) {
		self.selectedId = selectedId
		self.stepVms = steps.map { Self.stepVM(step: $0, selection: selectedId)}
		self.stepVms.forEach {print("\($0.id) is selected: \($0.isSelected)")}
		self.didSelect = didSelect
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
			Text(viewModel.title.uppercased())
				.fixedSize(horizontal: true, vertical: false)
				.lineLimit(1)
				.font(.medium10)
				.foregroundColor(Color(hex: "909090"))
		}.onTapGesture {
			self.didSelect(viewModel.id)
		}
	}

	var body: some View {
		CollectionView(stepVms, id: \.id) {
			stepView(for: $0)
				.frame(width: 80, height: 50)
		}
		.axis(.horizontal)
		.indicators(false)
		.groupSize(
			.init(
				widthDimension: .absolute(80),
				heightDimension: .absolute(50)))
			.itemSize(.init(widthDimension: .absolute(80),
											heightDimension: .absolute(50)))
			.layout({ (layout) in
				layout.interGroupSpacing = 24
			})
	}
}
