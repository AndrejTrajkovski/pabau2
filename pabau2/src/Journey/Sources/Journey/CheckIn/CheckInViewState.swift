import Model
import ComposableArchitecture
import Form
import Overture

public struct CheckInViewState: Equatable {
	var forms: Forms
	var xButtonActiveFlag: Bool
	let journey: Journey
	let journeyMode: JourneyMode

	func isEqual(int1: Int, int2: Int) -> Bool { return int1 == int2 }

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
