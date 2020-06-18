import Model
import ComposableArchitecture

public struct CheckInViewState: Equatable {
	var selectedIndex: Int
	var forms: [MetaFormAndStatus]
	var xButtonActiveFlag: Bool
	let journey: Journey

	var selectedForm: MetaFormAndStatus? {
		return forms[safe: selectedIndex]
	}

	var topView: TopViewState {
		get {
			TopViewState(totalSteps:
				self.forms
					.filter { extract(case: MetaForm.patientComplete, from: $0.form) == nil }
					.count,
									 completedSteps: self.forms.filter(\.isComplete).count,
									 xButtonActiveFlag: xButtonActiveFlag,
									 journey: journey)
		}
		set {
			self.xButtonActiveFlag = newValue.xButtonActiveFlag
		}
	}

	var isOnCompleteStep: Bool {
		guard let selectedForm = selectedForm else { return false}
		return stepType(form: selectedForm.form) == .patientComplete
	}

	var stepsViewState: StepsViewState {
		get {
			StepsViewState(selectedIndex: self.selectedIndex,
										 forms: self.forms)
		}
		set {
			self.selectedIndex = newValue.selectedIndex
			self.forms = newValue.forms
		}
	}

	var footer: FooterButtonsState {
		get {
			FooterButtonsState(forms: self.forms,
												 selectedIndex: selectedIndex,
												 selectedForm: selectedForm)
		}
		set {
			self.forms = newValue.forms
			self.selectedIndex = newValue.selectedIndex
		}
	}
}
