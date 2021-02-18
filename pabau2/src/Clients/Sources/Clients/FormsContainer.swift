import SwiftUI
import ComposableArchitecture
import Form
import Model
import Util

public let formsContainerReducer: Reducer<FormsContainerState, FormsContainerAction, FormEnvironment> = .combine(
	chooseFormListReducer.optional.pullback(
		state: \FormsContainerState.chooseForms,
		action: /FormsContainerAction.chooseForms,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .chooseForms(.proceed):
			state.isFillingFormsActive = true
			guard state.chooseForms != nil else { break }
			let array = state.chooseForms!.selectedTemplates().map { HTMLFormParentState.init(info: $0) }
			state.formsCollection = IdentifiedArray(array)
			guard let first = state.chooseForms!.selectedTemplates().first else { return .none }
			return env.formAPI.getTemplate(id: first.id)
				.catchToEffect()
				.receive(on: DispatchQueue.main)
				.map { FormsContainerAction.forms(id: first.id, action: .gotForm($0))}
				.eraseToEffect()
		default:
			break
		}
		return .none
	},
	htmlFormParentReducer.forEach(
		state: \FormsContainerState.formsCollection,
		action: /FormsContainerAction.forms,
		environment: { $0 })
)

public struct FormsContainerState: Equatable {
	let formType: FormType
	var chooseForms: ChooseFormState?
	var isFillingFormsActive: Bool
	var formsCollection: IdentifiedArrayOf<HTMLFormParentState>
	public var selectedIdx: Int
}

public enum FormsContainerAction: Equatable {
	case chooseForms(ChooseFormAction)
	case forms(id: HTMLForm.ID, action: HTMLFormParentAction)
	case checkIn(CheckInAction)
}

extension FormsContainerState: CheckInState {
	public func stepForms() -> [StepFormInfo] {
		formsCollection.map { StepFormInfo.init(status: $0.isComplete, title: $0.form?.title ?? "")}
	}
}

struct FormsContainer: View {
	let store: Store<FormsContainerState, FormsContainerAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			Group {
				IfLetStore(store.scope(state: { $0.chooseForms },
									   action: { .chooseForms($0) }),
						   then: { chooseFormsStore in
							ChooseFormList(store: chooseFormsStore, mode: .consentsCheckIn)
						   })
				NavigationLink.emptyHidden(viewStore.isFillingFormsActive,
										   CheckIn.init(store: store.scope(state: { $0 },
																		   action: { .checkIn($0)}),
														avatarView: { Text("avatar") },
														content: {
															ForEachStore(store.scope(state: { $0.formsCollection },
																					 action: FormsContainerAction.forms(id: action:)),
																		 content: HTMLFormParent.init(store:)
															)
														})
				)
			}
		}
	}
}
