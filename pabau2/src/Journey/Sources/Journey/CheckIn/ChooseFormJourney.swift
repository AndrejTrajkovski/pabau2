import SwiftUI
import ComposableArchitecture
import Model

struct ChooseFormJourney: View {
	let store: Store<ChooseFormState, ChooseFormAction>
	let mode: ChooseFormMode
	let journey: Journey?
	
	var body: some View {
		ChooseFormList(store: self.store,
									 mode: self.mode)
			.journeyBase(self.journey, .long)
	}
}
