import ComposableArchitecture
import Model

public protocol CheckInState {
	var selectedIdx: Int { get set }
	func stepForms() -> [StepFormInfo]
}

public extension CheckInState {

	mutating func select(idx: Int) {
		selectedIdx = idx
	}

	mutating func next() -> Bool {
		if stepForms().count - 1 > selectedIdx {
			selectedIdx += 1
			return true
		}
		return false
	}

	mutating func previous() -> Bool  {
		if selectedIdx > 0 {
			selectedIdx -= 1
			return true
		}
		return false
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
			_ = state.next()
		case .didSelectPrevStep:
			_ = state.previous()
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
