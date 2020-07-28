import ModelPackage
import ComposableArchitecture

public struct CheckInViewState: Equatable {
	var selectedIndex: Int
	var forms: [MetaFormAndStatus]
	var xButtonActiveFlag: Bool
	let journey: Journey

	var selectedForm: MetaFormAndStatus? {
		return forms[safe: selectedIndex]
	}

	var isOnPatientCompleteStep: Bool {
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
