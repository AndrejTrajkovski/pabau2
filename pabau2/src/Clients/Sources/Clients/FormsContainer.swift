import SwiftUI
import ComposableArchitecture
import Form
import Model
import Util
import Avatar

public let formsContainerReducer: Reducer<FormsContainerState, FormsContainerAction, FormEnvironment> = .combine(
	chooseFormListReducer.optional().pullback(
		state: \FormsContainerState.chooseForms,
		action: /FormsContainerAction.chooseForms,
		environment: { $0 }
	),
	.init { state, action, env in

	switch action {

		case .chooseForms(.proceed):
			guard state.chooseForms != nil else { break }
			let array = state.chooseForms!.selectedTemplates().map { HTMLFormParentState.init(info: $0, clientId: state.client.id, getLoadingState: .loading) }
			state.formsCollection = IdentifiedArray(array)
			state.isFillingFormsActive = true
			return .concatenate (
				state.formsCollection.map { htmlFormParentState in
					env.formAPI.getForm(templateId: htmlFormParentState.templateId, entryId: nil)
						.catchToEffect()
						.map(HTMLFormAction.gotForm)
						.map { FormsContainerAction.forms(id: htmlFormParentState.templateId, action: $0)}
						.receive(on: DispatchQueue.main)
						.eraseToEffect()
				}
			).receive(on: DispatchQueue.main)
			.eraseToEffect()
			
	default:
			break
		}
		return .none
	},
	htmlFormParentReducer.forEach(
		state: \FormsContainerState.formsCollection,
		action: /FormsContainerAction.forms,
		environment: { $0 }
	),
	CheckInReducer().reducer.pullback(
		state: \FormsContainerState.checkIn,
		action: /FormsContainerAction.checkIn,
		environment: { $0 }
	)
)

public struct FormsContainerState: Equatable {
	let client: Client
	let formType: FormType
	var chooseForms: ChooseFormState?
	var isFillingFormsActive: Bool
	var formsCollection: IdentifiedArrayOf<HTMLFormParentState>
	public var selectedIdx: Int
}

public enum FormsContainerAction: Equatable {
	case chooseForms(ChooseFormAction)
	case forms(id: HTMLForm.ID, action: HTMLFormAction)
	case checkIn(CheckInAction)
}

extension FormsContainerState {
	
	var checkIn: CheckInState {
		get {
			CheckInState(selectedIdx: self.selectedIdx,
						 stepForms: stepForms())
		}
		set {
			self.selectedIdx = newValue.selectedIdx
		}
	}
	
	private func stepForms() -> [StepFormInfo] {
        formsCollection.map { StepFormInfo.init(status: StepStatus.init(formStatus:$0.status), title: $0.templateName )}
	}
}

struct FormsContainer: View {
	let store: Store<FormsContainerState, FormsContainerAction>
	var body: some View {
		WithViewStore(store.scope(state: { $0.isFillingFormsActive })) { viewStore in
			IfLetStore(store.scope(state: { $0.chooseForms },
								   action: { .chooseForms($0) }),
					   then: { chooseFormsStore in
						Group {
							VStack {
								ClientAvatarAndName(store: store.scope(state: { $0.client }).actionless).padding()
								ChooseFormList(store: chooseFormsStore)
							}
							checkInNavigationLink(isActive: viewStore.state)
						}
					   }, else: { checkInView() }
			)
		}
	}

	func checkInNavigationLink(isActive: Bool) -> some View {
		NavigationLink.emptyHidden(isActive,
								   checkInView()
		)
	}

	@ViewBuilder
	func checkInView() -> some View {
		CheckInForms(store: store.scope(state: { $0.checkIn },
										action: { .checkIn($0)}),
					 avatarView: {
						ClientAvatarAndName(store: store.scope(state: { $0.client }).actionless) },
					 content: {
						ForEachStore(store.scope(state: { $0.formsCollection },
												 action: FormsContainerAction.forms(id: action:)),
                                     content: { formStore in
                                        HTMLFormParent.init(store: formStore,
                                                            footer: { completeBtn(store: formStore) }
                                        )
                                     }
						).padding([.leading, .trailing], 32)
					 }
		)
	}
    
    @ViewBuilder
    func completeBtn(store: Store<HTMLFormParentState, HTMLFormAction>) -> some View {
        IfLetStore(store.scope(state: { $0.form }, action: { .rows($0)}),
                   then: HTMLFormCompleteBtn.init(store:))
    }
}

struct ClientAvatarAndName: View {
	let store: Store<Client, Never>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				ClientAvatar(store: store)
				Text(viewStore.fullname)
					.font(Font.semibold24)
			}
		}
	}
}
