import SwiftUI
import ComposableArchitecture
import Model
import Combine
import Util
import CasePaths

struct ClientCardChildWrapper: View {
	let store: Store<ClientCardState, ClientCardBottomAction>
	@ObservedObject var viewStore: ViewStore<ClientCardGridItem?, ClientCardBottomAction>

	init(store: Store<ClientCardState, ClientCardBottomAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: { $0.activeItem }))
	}

	var body: some View {
		print("CC Child")
		if viewStore.state == .details {
			return AnyView(
				ChildViewHolder(child: PatientDetailsClientCard.self,
																		 store:
				self.store.scope(state: { $0.list.details },
												 action: { .child(.details($0) )})
				)
			)
		} else if viewStore.state == .appointments {
			return AnyView(ChildViewHolder(child: AppointmentsList.self,
																		 store:
				self.store.scope(state: { $0.list.appointments },
												 action: { .child(.appointments($0) )}))
			)
		} else if viewStore.state == .documents {
			return AnyView(ChildViewHolder(child: DocumentsList.self,
																		 store:
				self.store.scope(state: { $0.list.documents },
												 action: { .child(.documents($0) )})
			))
		} else if viewStore.state == .photos {
			return AnyView(ChildViewHolder(child: CCPhotos.self,
																		 store:
				self.store.scope(state: { $0.list.photos },
												 action: { .child(.photos($0) )})
			))
		} else if viewStore.state == .financials {
			return AnyView(ChildViewHolder(child: FinancialsList.self,
																		 store:
				self.store.scope(state: { $0.list.financials },
												 action: { .child(.financials($0) )})
			))
		} else if viewStore.state == .treatmentNotes {
			return AnyView(ChildViewHolder(child: FormsList.self,
																		 store:
				self.store.scope(state: { $0.list.treatmentNotes },
												 action: { .child(.treatmentNotes($0) )})
			))
		} else if viewStore.state == .consents {
			return AnyView(ChildViewHolder(child: FormsList.self,
																		 store:
				self.store.scope(state: { $0.list.consents },
												 action: { .child(.consents($0) )})
			))
		} else if viewStore.state == .prescriptions {
			return AnyView(ChildViewHolder(child: FormsList.self,
																		 store:
				self.store.scope(state: { $0.list.prescriptions },
												 action: { .child(.prescriptions($0) )})
			))
		} else if viewStore.state == .communications {
			return AnyView(ChildViewHolder(child: CommunicationsList.self,
																		 store:
				self.store.scope(state: { $0.list.communications },
												 action: { .child(.communications($0) )})
			))
		} else if viewStore.state == .alerts {
			return AnyView(ChildViewHolder(child: AlertsList.self,
                                           store: self.store.scope(state: { $0.list.alerts },
                                                                   action: { .child(.alerts($0)) })
			))
		} else if viewStore.state == .notes {
			return AnyView(ChildViewHolder(child: NotesList.self,
                                           store: self.store.scope(state: { $0.list.notes },
                                                                   action: { .child(.notes($0) )})
			))
		} else {
			return AnyView(EmptyView())
		}
	}
}
//case alerts
//case notes

struct ClientCardChildReducer<T: Equatable> {
	let reducer = Reducer<ClientCardChildState<T>, GotClientListAction<T>, ClientsEnvironment> { state, action, _ in
		switch action {
		case .gotResult(let result):
			switch result {
			case .failure(let error):
				state.loadingState = .gotError(error)
			case .success(let success):
				state.loadingState = .gotSuccess
				state.state = success
			}
		}
		return .none
	}
}

public struct ClientCardListState: Equatable {
    let client: Client
	var appointments: AppointmentsListState
	var details: PatientDetailsClientCardState
	var photos: CCPhotosState
	var financials: ClientCardChildState<[Financial]>
	var treatmentNotes: FormsListState
	var prescriptions: FormsListState
	var documents: DocumentsListState
	var communications: ClientCardChildState<[Communication]>
	var consents: FormsListState
    var alerts: ClientAlertsState
    var notes: NotesListState

    init(client: Client) {
        self.client = client
		self.appointments = AppointmentsListState(
			childState: ClientCardChildState.init(state: [])
		)
		self.details = PatientDetailsClientCardState(childState: ClientCardChildState.init(state: PatientDetails.mock))
		self.photos = CCPhotosState.init(childState: ClientCardChildState.init(state: [:]))
		self.financials = ClientCardChildState.init(state: [])
		self.treatmentNotes = FormsListState(client: client, childState: ClientCardChildState(state: []), formType: .treatment)
		self.prescriptions = FormsListState(client: client, childState: ClientCardChildState(state: []), formType: .prescription)
		self.documents = DocumentsListState(childState:
		ClientCardChildState.init(state: []))
		self.communications = ClientCardChildState.init(state: [])
		self.consents = FormsListState(client: client, childState: ClientCardChildState(state: []), formType: .consent)
        self.alerts = ClientAlertsState(client: client, childState: ClientCardChildState(state: []))
        self.notes = NotesListState.init(client: client, childState: ClientCardChildState(state: []))
		self.consents = FormsListState(client: client, childState: ClientCardChildState(state: []), formType: .consent)
	}
}

public struct ClientCardChildState<T: Equatable>: Equatable {
	var state: T
	var loadingState: LoadingState = .initial
}

public enum GotClientListAction<T: Equatable>: Equatable {
	case gotResult(Result<T, RequestError>)
}

public enum ClientCardChildAction: Equatable {
	case appointments(AppointmentsListAction)
	case details(PatientDetailsClientCardAction)
	case photos(CCPhotosAction)
	case financials(GotClientListAction<[Financial]>)
	case treatmentNotes(FormsListAction)
	case prescriptions(FormsListAction)
	case documents(DocumentsListAction)
	case communications(GotClientListAction<[Communication]>)
	case consents(FormsListAction)
    case alerts(ClientAlertsAction)
    case notes(NotesListAction)
}

let clientCardListReducer: Reducer<ClientCardListState, ClientCardChildAction, ClientsEnvironment> = Reducer.combine(
	appointmentsListReducer.pullback(
		state: \ClientCardListState.appointments,
		action: /ClientCardChildAction.appointments,
		environment: { $0 }
	),
	ccPhotosReducer.pullback(
		state: \ClientCardListState.photos,
		action: /ClientCardChildAction.photos,
		environment: { $0 }),
	patientDetailsClientCardReducer.pullback(
		state: \ClientCardListState.details,
		action: /ClientCardChildAction.details,
		environment: { $0 }
	),
	ClientCardChildReducer<[Financial]>().reducer.pullback(
		state: \ClientCardListState.financials,
		action: /ClientCardChildAction.financials,
		environment: { $0 }
	),
	formsListReducer.pullback(
		state: \ClientCardListState.treatmentNotes,
		action: /ClientCardChildAction.treatmentNotes,
		environment: { $0 }
	),
	formsListReducer.pullback(
		state: \ClientCardListState.prescriptions,
		action: /ClientCardChildAction.prescriptions,
		environment: { $0 }
	),
	ClientCardChildReducer<[Document]>().reducer.pullback(
		state: \ClientCardListState.documents.childState,
		action: /ClientCardChildAction.documents..DocumentsListAction.action,
		environment: { $0 }
	),
	ClientCardChildReducer<[Communication]>().reducer.pullback(
		state: \ClientCardListState.communications,
		action: /ClientCardChildAction.communications,
		environment: { $0 }
	),
	formsListReducer.pullback(
		state: \ClientCardListState.consents,
		action: /ClientCardChildAction.consents,
		environment: { $0 }
	),
    clientAlertsReducer.pullback(
        state: \ClientCardListState.alerts,
        action: /ClientCardChildAction.alerts,
        environment: { $0 }
    ),
    clientNotesListReducer.pullback(
        state: \ClientCardListState.notes,
        action: /ClientCardChildAction.notes,
        environment: { $0 }
    )
)

protocol ClientCardChildParentAction: Equatable {
	associatedtype T: Equatable
	var action: GotClientListAction<T>? { get set }
}

protocol ClientCardChildParentState: Equatable {
	associatedtype T: Equatable
	var childState: ClientCardChildState<T> { get set }
}

protocol ClientCardChild: View {
	associatedtype State: ClientCardChildParentState
	associatedtype Action: ClientCardChildParentAction
	var store: Store<State, Action> { get }
	init(store: Store<State, Action>)
}

struct ChildViewHolder< U, V,
Child: ClientCardChild>: View where U == Child.State, V == Child.Action {
	let store: Store<U, V>
	let child: Child.Type
	init(child: Child.Type,
			 store: Store<U, V>) {
		self.child = child
		self.store = store
	}
	var body: some View {
		WithViewStore(store) { viewStore in
			ViewBuilder.buildBlock(
				(viewStore.state.childState.loadingState == .loading) ?
					ViewBuilder.buildEither(second: LoadingView(title: "Loading",
																											bindingIsShowing: .constant(true), content: { EmptyView() }))
					:
					ViewBuilder.buildEither(first: Child.init(store: self.store)
				)
			)
		}
	}
}
