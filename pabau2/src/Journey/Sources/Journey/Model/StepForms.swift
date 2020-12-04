import ComposableArchitecture
import Model
import Form
import Util

public struct StepForms: Equatable, Identifiable {
	let stepType: StepType
	var forms: IdentifiedArrayOf<MetaFormAndStatus>
	var selFormIndex: Int = 0

	var selectedForm: MetaFormAndStatus? {
		self.forms[safe: selFormIndex]
	}

	public var id: StepType { stepType }

	var isComplete: Bool {
		self.forms.allSatisfy(\.isComplete)
	}

	mutating func previousIndex() -> Bool {
		if selFormIndex > 0 {
			selFormIndex -= 1
			return true
		} else {
			return false
		}
	}

	mutating func nextIndex() -> Bool {
		if forms.count - 1 > selFormIndex {
			selFormIndex += 1
			return true
		} else {
			return false
		}
	}
}
