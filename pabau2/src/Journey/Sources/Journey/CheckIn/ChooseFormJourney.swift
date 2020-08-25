import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public let chooseFormJourneyReducer: Reducer<ChooseFormJourneyState,
	ChooseFormAction, JourneyEnvironment> = .combine(
		chooseFormListReducer.pullback(
			state: \.chooseForm,
			action: /ChooseFormAction.self,
			environment: { $0 }
		)
		,
		Reducer.init { state, action , env in
			switch action {
			case .proceed:
				//TODO:
				updateWithKeepingOld(forms: &state.forms,
														 finalSelectedTemplatesIds: state.selectedTemplatesIds,
														 allTemplates: state.templates)
				return .none
			default: break
			}
			return .none
		}
)

public struct ChooseFormJourneyState: Equatable {
	var forms: IdentifiedArrayOf<MetaFormAndStatus>
	var templates: IdentifiedArrayOf<FormTemplate>
	var templatesLoadingState: LoadingState = .initial
	var selectedTemplatesIds: [Int]
}

struct ChooseFormJourney: View {
	let store: Store<ChooseFormJourneyState, ChooseFormAction>
	let mode: ChooseFormMode
	let journey: Journey?
	
	var body: some View {
		ChooseFormList(store:
			self.store.scope(
				state: { $0.chooseForm }, action: { $0 }),
									 mode: self.mode)
			.journeyBase(self.journey, .long)
	}
}

extension ChooseFormJourneyState {
	var chooseForm: ChooseFormState {
		get {
			ChooseFormState(
				templates: self.templates,
				templatesLoadingState: self.templatesLoadingState,
				selectedTemplatesIds: self.selectedTemplatesIds
			)
		}
		set {
			self.templates = newValue.templates
			self.templatesLoadingState = newValue.templatesLoadingState
			self.selectedTemplatesIds = newValue.selectedTemplatesIds
		}
	}
}
