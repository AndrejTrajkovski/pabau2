import Model
import ComposableArchitecture
import Form
import Overture

public struct CheckInViewState: Equatable {
	var forms: Forms
	var xButtonActiveFlag: Bool
	let journey: Journey
	let journeyMode: JourneyMode

	var footer: FooterButtonsState {
		get {
			FooterButtonsState(forms: self.forms,
							   journeyMode: journeyMode)
		}
		set {
			self.forms = newValue.forms
		}
	}
}
