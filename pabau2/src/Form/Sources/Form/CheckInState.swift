import ComposableArchitecture
import Model

public protocol CheckInState {
	var selectedIdx: Int { get set }
	func stepForms() -> [StepFormInfo]
}

extension CheckInState {

	mutating func select(idx: Int) {
		selectedIdx = idx
	}

	mutating func next() {
		if stepForms().count - 1 > selectedIdx {
			selectedIdx += 1
		}
	}

	mutating func previous() {
		if selectedIdx > 0 {
			selectedIdx -= 1
		}
	}

	mutating func goToNextUncomplete() {
		stepForms().firstIndex(where: { !$0.status }).map {
			selectedIdx = $0
		}
	}
}

public struct CheckInReducer<T: CheckInState> {
	public init () { }
	public let reducer = Reducer<T, CheckInAction, FormEnvironment> { state, action, _ in
		switch action {
		case .didSelectFlatFormIndex(let idx):
			state.selectedIdx = idx
		case .didSelectNextStep:
			state.next()
		case .didSelectPrevStep:
			state.previous()
		case .onXTap:
			break
		}
		return .none
	}
}

public enum CheckInAction: Equatable {
	case didSelectFlatFormIndex(Int)
	case didSelectNextStep
	case didSelectPrevStep
	case onXTap
}
