import Util
import SwiftUI
import Model
import ComposableArchitecture
import Form

public protocol StepsViewState {
	var journey: Journey { get }
	var forms: [MetaFormAndStatus] { get }
	var selectedIdx: Int { get set }
	func selectedForm() -> MetaFormAndStatus
}

extension StepsViewState {

	func selectedForm() -> MetaFormAndStatus {
		forms[selectedIdx]
	}
	
	mutating func select(idx: Int) {
		selectedIdx = idx
	}
	
	mutating func next() {
		if forms.count - 1 > selectedIdx {
			selectedIdx += 1
		}
	}

	mutating func previous() {
		if selectedIdx > 0 {
			selectedIdx -= 1
		}
	}

	mutating func goToNextUncomplete() {
		forms.firstIndex(where: { !$0.isComplete }).map {
			selectedIdx = $0
		}
	}
}

let stepsViewReducer = Reducer<StepsViewState, StepsViewAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didSelectFlatFormIndex(let idx):
		state.selectedIdx = idx
	case .didSelectNextStep:
		state.next()
	case .didSelectPrevStep:
		state.previous()
	}
	return .none
}

public struct StepSelectorElement: Equatable {
	let isComplete: Bool
	let title: String
}

public enum StepsViewAction {
	case didSelectFlatFormIndex(Int)
	case didSelectNextStep
	case didSelectPrevStep
}

struct StepSelector: View {
	let cellWidth: CGFloat = 100
	let cellHeight: CGFloat = 80
	let spacing: CGFloat = 8
	
	struct State: Equatable {
		let maxVisibleCells = 5
		let stepForms: [StepSelectorElement]
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

	var body: some View {
		HStack(alignment: .top, spacing: 24) {
			if viewStore.state.shouldShowLeftArrow { previousArrow() }
			scrollView()
			if viewStore.state.shouldShowRightArrow { nextArrow() }
		}
	}

	fileprivate func scrollView() -> some View {
		ScrollViewReader { scrollProxy in
			ScrollView(.horizontal) {
				HStack(spacing: spacing) {
					ForEach(viewStore.state.stepForms.indices, id: \.self) { idx in
						stepView(for: viewStore.state.stepForms[idx])
							.frame(width: cellWidth, height: cellHeight)
							.onTapGesture {
								self.viewStore.send(.didSelectFlatFormIndex(idx))
								withAnimation {
									scrollProxy.scrollTo(idx, anchor: .center)
								}
							}
					}
				}
			}.frame(width: ((cellWidth + spacing) * CGFloat(viewStore.state.numberOfVisibleSteps)),
					height: cellHeight)
		}
	}

	func stepView(for viewModel: StepSelectorElement) -> some View {
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
		}
	}

	fileprivate func previousArrow() -> some View {
		Image(systemName: "chevron.left")
			.font(.regular30).foregroundColor(Color(hex: "909090"))
			.onTapGesture {
				self.viewStore.send(.didSelectPrevStep)
			}
	}

	fileprivate func nextArrow() -> some View {
		Image(systemName: "chevron.right")
			.font(.regular30).foregroundColor(Color(hex: "909090"))
			.onTapGesture {
				self.viewStore.send(.didSelectNextStep)
			}
	}
}

extension StepSelector.State {
	init(state: StepsViewState) {
		let stepForms = zip(state.forms, state.forms.indices).map {
			StepSelectorElement(isComplete: $0.0.isComplete,
								title: $0.0.form.title)
		}
		let shouldShowArrows = stepForms.count > maxVisibleCells
		self.stepForms = stepForms
		self.selectedIndex = state.selectedIdx
		self.numberOfVisibleSteps = min(stepForms.count, maxVisibleCells)
		self.shouldShowLeftArrow = shouldShowArrows && (state.selectedIdx != 0)
		self.shouldShowRightArrow = shouldShowArrows && (state.selectedIdx != stepForms.count - 1)
	}
}
