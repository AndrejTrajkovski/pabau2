import Model
import ComposableArchitecture
import Form
import Overture

public struct CheckInViewState: Equatable {
	var selectedIndex: Int
	var forms: IdentifiedArrayOf<StepForms>
	var selectedStepType: StepType
	var xButtonActiveFlag: Bool
	let journey: Journey
	let journeyMode: JourneyMode
	
	func isEqual(int1: Int, int2: Int) -> Bool { return int1 == int2 }
	
	var selectedForm: MetaFormAndStatus? {
		return zip(forms.flatMap(\.forms),forms.flatMap(\.forms).indices)
			.first(where: pipe(get(\(MetaFormAndStatus, Int).1),
												 with(self.selectedIndex, curry(isEqual(int1:int2:)))))
			.map(\.0)
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
												 selectedStepType: selectedStepType,
												 selectedForm: selectedForm,
												 journeyMode: journeyMode)
		}
		set {
			self.forms = newValue.forms
			self.selectedIndex = newValue.selectedIndex
			self.selectedStepType = newValue.selectedStepType
		}
	}
}
