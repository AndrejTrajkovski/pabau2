import Util
import SwiftUI
import Model

struct StepsCollectionView: View {
	let formVms: [FormVM]
	let selectedIdx: Int
	let didSelect: (Int) -> Void

	init (steps: [MetaForm], selectedIdx: Int, didSelect: @escaping (Int) -> Void) {
		self.selectedIdx = selectedIdx
		self.formVms = zip(steps, steps.indices).map { Self.stepVM(step: $0, selection: selectedIdx)}
		self.formVms.forEach {print("\($0.idx) is selected: \($0.isSelected)")}
		self.didSelect = didSelect
	}

	struct FormVM {
		let idx: Int
		let isSelected: Bool
		let title: String
	}

	static func stepVM(step: (MetaForm, Int), selection: Int) -> FormVM {
		FormVM(idx: step.1,
					 isSelected: step.1 == selection,
					 title: step.0.title)
	}
	
	func stepView(for viewModel: FormVM) -> some View {
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
			self.didSelect(viewModel.idx)
		}
	}

	var body: some View {
		CollectionView(formVms, id: \.idx) {
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
