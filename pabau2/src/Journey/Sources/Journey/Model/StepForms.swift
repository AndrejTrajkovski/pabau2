import ComposableArchitecture
import Model
import Form

public struct StepForms: Equatable, Identifiable {
	var stepType: StepType
	var forms: IdentifiedArray<Int, MetaFormAndStatus>
	var selFormIndex: Int

	var selectedForm: MetaFormAndStatus {
		self.forms[selFormIndex]
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
