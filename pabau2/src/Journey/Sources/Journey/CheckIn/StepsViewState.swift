import ComposableArchitecture
import Model

protocol StepsViewState {
	var journey: Journey { get }
	var stepForms: [StepFormInfo] { get }
	var selectedIdx: Int { get set }
	func stepTypes() -> [StepType]
}

extension StepsViewState {

	mutating func select(idx: Int) {
		selectedIdx = idx
	}

	mutating func next() {
		if stepForms.count - 1 > selectedIdx {
			selectedIdx += 1
		}
	}

	mutating func previous() {
		if selectedIdx > 0 {
			selectedIdx -= 1
		}
	}

	mutating func goToNextUncomplete() {
		stepForms.firstIndex(where: { !$0.status }).map {
			selectedIdx = $0
		}
	}
}

struct StepsViewReducer<T: StepsViewState> {
	let reducer = Reducer<T, StepsViewAction, JourneyEnvironment> { state, action, _ in
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
}

public enum StepsViewAction {
	case didSelectFlatFormIndex(Int)
	case didSelectNextStep
	case didSelectPrevStep
}
