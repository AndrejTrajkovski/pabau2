import Util
import SwiftUI
import Model
import ComposableArchitecture
import Form

struct StepsViewState: Equatable {
	var forms: Forms
}

public enum StepsViewAction {
	case didSelectFlatFormIndex(Int)
	case didSelectNextStep
	case didSelectPrevStep
}

let stepsViewReducer = Reducer<StepsViewState, StepsViewAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didSelectFlatFormIndex(let idx):
		state.forms.flatSelectedIndex = idx
	case .didSelectNextStep:
		state.forms.next()
	case .didSelectPrevStep:
		state.forms.previous()
	}
	return .none
}

struct StepsCollectionView: View {
	let cellWidth: CGFloat = 100
	let cellHeight: CGFloat = 80
	let spacing: CGFloat = 8
	struct State: Equatable {
		let maxVisibleCells = 5
		let formVms: [FormVM]
		let selectedIndex: Int
		let numberOfVisibleSteps: Int
		let shouldShowLeftArrow: Bool
		let shouldShowRightArrow: Bool
	}

	let store: Store<StepsViewState, StepsViewAction>
	@ObservedObject var viewStore: ViewStore<State, StepsViewAction>
	init (store: Store<StepsViewState, StepsViewAction>) {
		self.store = store
		self.viewStore = ViewStore(
			store.scope( state: State.init(state:), action: { $0 }))
	}

	func stepView(for viewModel: FormVM) -> some View {
		VStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(viewModel.isComplete ? .blue : Color(hex: "C7C7CC"))
				.frame(width: 30, height: 30)
			Text(viewModel.title.uppercased())
				.fixedSize(horizontal: false, vertical: true)
				.multilineTextAlignment(.center)
				.lineLimit(nil)
				.font(.medium10)
				.foregroundColor(Color(hex: "909090"))
		}.onTapGesture {
			self.viewStore.send(.didSelectFlatFormIndex(viewModel.idx))
		}.frame(maxWidth: cellWidth, maxHeight: cellHeight, alignment: .top)
	}

	var body: some View {
		HStack(alignment: .top, spacing: 24) {
			if viewStore.state.shouldShowLeftArrow {
				Image(systemName: "chevron.left")
					.font(.regular30).foregroundColor(Color(hex: "909090"))
					.onTapGesture {
						self.viewStore.send(.didSelectPrevStep)
				}
			}
			CollectionView(viewStore.state.formVms, viewStore.state.selectedIndex) {
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
				.frame(width: ((cellWidth + spacing) * CGFloat(viewStore.state.numberOfVisibleSteps)),
							 height: cellHeight)
			if viewStore.state.shouldShowRightArrow {
				Image(systemName: "chevron.right")
					.font(.regular30).foregroundColor(Color(hex: "909090"))
					.onTapGesture {
						self.viewStore.send(.didSelectNextStep)
				}
			}
		}
	}
}

extension StepsCollectionView.State {
	init(state: StepsViewState) {
		let forms = state.forms
		let selIdx = state.forms.flatSelectedIndex
		let formVms = zip(forms.flat, forms.flat.indices).map { Self.formVm(form: $0, selection: selIdx)}
		let shouldShowArrows = formVms.count > maxVisibleCells
		self.formVms = formVms
		self.selectedIndex = selIdx
		self.numberOfVisibleSteps = min(formVms.count, maxVisibleCells)
		self.shouldShowLeftArrow = shouldShowArrows && (selIdx != 0)
		self.shouldShowRightArrow = shouldShowArrows && (selIdx != formVms.count - 1)
	}

	static func formVm(form: (MetaFormAndStatus, Int), selection: Int) -> FormVM {
		FormVM(idx: form.1,
					 isComplete: form.0.isComplete,
					 title: form.0.form.title)
	}
}

struct FormVM: Hashable {
	let idx: Int
	let isComplete: Bool
	let title: String
}
