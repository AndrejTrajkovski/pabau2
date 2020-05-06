import Util
import SwiftUI
import Model

struct StepsCollectionView: View {

	let maxVisibleCells = 5
	let cellWidth: CGFloat = 100
	let cellHeight: CGFloat = 80
	let spacing: CGFloat = 8

	let formVms: [FormVM]
	let selectedIdx: Int
	let didSelect: (Int) -> Void

	init (steps: [MetaFormAndStatus],
				selectedIdx: Int,
				didSelect: @escaping (Int) -> Void) {
		self.selectedIdx = selectedIdx
		self.formVms = zip(steps, steps.indices).map { Self.stepVM(step: $0, selection: selectedIdx)}
		self.formVms.forEach {print("\($0.idx) is selected: \($0.isSelected)")}
		self.didSelect = didSelect
	}

	struct FormVM: Hashable {
		let idx: Int
		let isSelected: Bool
		let title: String
	}

	static func stepVM(step: (MetaFormAndStatus, Int), selection: Int) -> FormVM {
		FormVM(idx: step.1,
					 isSelected: step.1 == selection,
					 title: step.0.form.title)
	}

	func stepView(for viewModel: FormVM) -> some View {
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
		CollectionView(formVms, selectedIdx) {
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
			.frame(width: ((cellWidth + spacing) * CGFloat(min(formVms.count, maxVisibleCells))),
						 height: cellHeight)
	}
}
