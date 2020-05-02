import Util
import SwiftUI
import Model

struct StepsCollectionView: View {

	let cellWidth: CGFloat = 100
	let cellHeight: CGFloat = 80
	let spacing: CGFloat = 8

	let stepVms: [StepVM]
	let selectedIdx: Int
	let didSelect: (Int) -> Void

	init (steps: [MetaFormAndStatus],
				selectedIdx: Int,
				journeyMode: JourneyMode,
				didSelect: @escaping (Int) -> Void) {
		self.selectedIdx = selectedIdx
		var stepVms = zip(steps, steps.indices).map { Self.stepVM(step: $0, selection: selectedIdx)}
		if journeyMode == .patient {
			stepVms.append(StepVM(idx: stepVms.count,
													isSelected: stepVms.count == selectedIdx,
													title: "COMPLETE"))
		}
		self.stepVms = stepVms
		self.didSelect = didSelect
	}

	struct StepVM: Hashable {
		let idx: Int
		let isSelected: Bool
		let title: String
	}

	static func stepVM(step: (MetaFormAndStatus, Int), selection: Int) -> StepVM {
		StepVM(idx: step.1,
					 isSelected: step.1 == selection,
					 title: step.0.form.title)
	}

	func stepView(for viewModel: StepVM) -> some View {
		VStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(viewModel.isSelected ? .blue : .gray)
				.frame(width: 30, height: 30)
			Text(viewModel.title.uppercased())
				.fixedSize(horizontal: false, vertical: true)
				.multilineTextAlignment(.center)
				.lineLimit(nil)
				.font(.medium10)
				.foregroundColor(Color(hex: "909090"))
		}.onTapGesture {
			self.didSelect(viewModel.idx)
		}.frame(maxWidth: cellWidth, maxHeight: cellHeight, alignment: .top)
	}

	var body: some View {
		HStack {
			Spacer()
				.fixedSize(horizontal: false, vertical: true)
			CollectionView(stepVms, selectedIdx) {
				stepView(for: $0)
			}
			.axis(.horizontal)
			.indicators(false)
			.groupSize(
				.init(
					widthDimension: .absolute(cellWidth),
					heightDimension: .absolute(cellHeight)))
				.itemSize(.init(widthDimension: .absolute(cellWidth),
												heightDimension: .absolute(cellHeight)))
				.layout({ (layout) in
					layout.interGroupSpacing = spacing
				})
				.frame(width: 480,
							 height: cellHeight)
		}
	}
}
