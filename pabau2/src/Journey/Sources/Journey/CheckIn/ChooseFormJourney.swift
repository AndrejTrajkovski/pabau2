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
			environment: makeFormEnv(_:)
		)
		,
		Reducer.init { state, action, _ in
			switch action {
			case .proceed:
				//TODO:
				let toGetIds = updateWithKeepingOld(
					forms: &state.forms,
					finalSelectedTemplatesIds: state.selectedTemplatesIds,
					allTemplates: state.templates
				)
				return .none
			default: break
			}
			return .none
		}
)

public struct ChooseFormJourneyState: Equatable {
	var forms: IdentifiedArrayOf<HTMLForm>
	var templates: IdentifiedArrayOf<FormTemplateInfo>
	var templatesLoadingState: LoadingState = .initial
	var selectedTemplatesIds: [HTMLForm.ID]
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

private func updateWithKeepingOld(forms: inout IdentifiedArray<HTMLForm.ID, HTMLForm>,
								  finalSelectedTemplatesIds: [HTMLForm.ID],
								  allTemplates: IdentifiedArrayOf<FormTemplateInfo>) -> [HTMLForm.ID] {
	let oldWithData = forms.filter { old in
		finalSelectedTemplatesIds.contains(old.id)
	}
	let allNewSelected = allTemplates.filter { finalSelectedTemplatesIds.contains($0.id) }
	let oldToKeepIds = allNewSelected.map(\.id).filter { oldWithData.map(\.id).contains($0)}
	let newToGetIds = allNewSelected.map(\.id).filter { oldToKeepIds.contains($0)}
	
	let oldToKeep = oldToKeepIds.compactMap { oldWithData[id: $0 ]}
	forms = IdentifiedArrayOf.init(oldToKeep)
	
	return newToGetIds
}
