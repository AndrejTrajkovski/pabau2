import SwiftUI
import ComposableArchitecture
import Form
import Model
import Util
import Avatar

public let formsContainerReducer: Reducer<FormsContainerState, FormsContainerAction, FormEnvironment> = .combine(
	chooseFormListReducer.optional.pullback(
		state: \FormsContainerState.chooseForms,
		action: /FormsContainerAction.chooseForms,
		environment: { $0 }
	),
	.init { state, action, env in
		func getForm(_ templateId: HTMLForm.ID, _ formAPI: FormAPI) -> Effect<FormsContainerAction, Never> {
			return formAPI.getForm(templateId: templateId)
				.catchToEffect()
				.receive(on: DispatchQueue.main)
				.map { FormsContainerAction.forms(id: templateId, action: .gotForm($0))}
				.eraseToEffect()
		}

	switch action {

		case .chooseForms(.proceed):
			guard state.chooseForms != nil else { break }
			let array = state.chooseForms!.selectedTemplates().map { HTMLFormParentState.init(info: $0, clientId: state.client.id, getLoadingState: .loading) }
			state.formsCollection = IdentifiedArray(array)
			state.isFillingFormsActive = true
			return .concatenate (
				state.formsCollection.map(\.id).map { getForm($0, env.formAPI) }
			)

		default:
			break
		}
		return .none
	},
	htmlFormParentReducer.forEach(
		state: \FormsContainerState.formsCollection,
		action: /FormsContainerAction.forms,
		environment: { $0 }
	).debug(),
	CheckInReducer<FormsContainerState>().reducer.pullback(
		state: \FormsContainerState.self,
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

extension FormsContainerState: CheckInState {
	public func stepForms() -> [StepFormInfo] {
		formsCollection.map { StepFormInfo.init(status: $0.status, title: $0.info.name )}
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
					   }, else: checkInView()
			)
		}.debug("Forms Container")
	}

	func checkInNavigationLink(isActive: Bool) -> some View {
		NavigationLink.emptyHidden(isActive,
								   checkInView()
		)
	}

	func checkInView() -> some View {
		print("FormsContainer")
		return CheckIn(store: store.scope(state: { $0 },
								   action: { .checkIn($0)}),
					   avatarView: {
						ClientAvatarAndName(store: store.scope(state: { $0.client }).actionless) },
				content: {
					ForEachStore(store.scope(state: { $0.formsCollection },
											 action: FormsContainerAction.forms(id: action:)),
								 content: HTMLFormParent.init(store:)
					).padding([.leading, .trailing], 32)
				}
		)
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
