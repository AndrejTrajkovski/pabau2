import SwiftUI
import ComposableArchitecture
import Model
import Combine
import Util
import CasePaths

protocol ClientCardChildParentAction: Equatable {
	associatedtype T: Equatable
	var action: GotClientListAction<T>? { get set }
}

protocol ClientCardChildParentState: Equatable {
	associatedtype T: Equatable
	var state: ClientCardChildState<T> { get set }
}

//struct ClientCardChildContainer<State: ClientCardChildParentState, Action: ClientCardChildParentAction, T: Equatable, ClientCardChildView: View>: View {
//	var store: Store<State, Action>
//	@ObservedObject var viewStore: ViewStore<State, Action>
////	var keyPath: KeyPath<State, ClientCardChildState<T>>
//	let makeChild: (Store<State, Action>) -> ClientCardChildView
//	var body: some View {
//		if self.viewStore.state.state.loadingState == .loading {
//			return AnyView(Text("Loading"))
//		} else {
//			return AnyView(makeChild(self.store))
//		}
//	}
//}

protocol ClientCardChild: View {
	associatedtype State: ClientCardChildParentState
	associatedtype Action: ClientCardChildParentAction
	var store: Store<State, Action> { get set }
	init(store: Store<State, Action>)
}
//KEYPATH
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
				(viewStore.state.state.loadingState == .loading) ?
					ViewBuilder.buildEither(second: LoadingView(title: "Loading",
																											bindingIsShowing: .constant(true), content: { EmptyView() }))
					:
					ViewBuilder.buildEither(first: Child.init(store: self.store)
				)
			)
		}
	}
}

struct ClientCardChildWrapper: View {
	let store: Store<ClientCardState, ClientCardBottomAction>
	@ObservedObject var viewStore: ViewStore<ClientCardState, ClientCardBottomAction>

	init(store: Store<ClientCardState, ClientCardBottomAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		if viewStore.state.activeItem == .details {
			return AnyView(
				ChildViewHolder(child: PatientDetailsClientCard.self,
																		 store:
				self.store.scope(state: { $0.list.details },
												 action: { .child(.details($0) )})
				)
			)
		} else if viewStore.state.activeItem == .appointments {
			return AnyView(ChildViewHolder(child: AppointmentsList.self,
																		 store:
				self.store.scope(state: { $0.list.appointments },
												 action: { .child(.appointments($0) )}))
			)
		} else if viewStore.state.activeItem == .documents {
			return AnyView(ChildViewHolder(child: DocumentsList.self,
																		 store:
				self.store.scope(state: { $0.list.documents },
												 action: { .child(.documents($0) )})
			))
		} else {
			return AnyView(EmptyView())
		}
//		else if viewStore.state.activeItem == .prescriptions {
//			return AnyView(ChildViewHolder(child: PrescriptionsList.self,
//																		 state: clientCardState.list.prescriptions))
//		} else if viewStore.state.activeItem == .treatmentNotes {
//			return AnyView(ChildViewHolder(child: TreatmentsList.self,
//																		 state: clientCardState.list.treatmentNotes))
//		} else if viewStore.state.activeItem == .consents {
//			return AnyView(ChildViewHolder(child: ConsentsList.self,
//																		 state: clientCardState.list.consents))
//		} else if viewStore.state.activeItem == .financials {
//			return AnyView(ChildViewHolder(child: FinancialsList.self,
//																		 state: clientCardState.list.financials))
//		} else if clientCardState.activeItem == .alerts {
//			return AnyView(ChildViewHolder(child: AlertsList.self,
//																		 state: clientCardState.list.alerts))
//		} else if clientCardState.activeItem == .notes {
//			return AnyView(ChildViewHolder(child: NotesList.self,
//																		 state: clientCardState.list.notes))
//		} else if clientCardState.activeItem == .communications {
//			return AnyView(ChildViewHolder(child: CommunicationsList.self,
//																		 state: clientCardState.list.communications))
//		}
//		else if clientCardState.activeItem == .photos {
//			return AnyView(ChildViewHolder(child: PhotosList.self,
//																		 state: clientCardState.list.photos))
//		}
//		else if clientCardState.activeItem == .details {
//			return AnyView(EmptyView())
//			return AnyView(ChildViewHolder(child: PatientDetails.self,
//																		 state: clientCardState.list.photos))
//		}
//		else { return AnyView(EmptyView()) }
//		ViewBuilder.buildBlock(
//			(clientCardState.activeItem == .appointments) ?
//				ViewBuilder.buildEither(second:
//					ChildViewHolder(makeView(appointments:),
//													state: clientCardState.list.appointments)
//				)
//				:
//				ViewBuilder.buildEither(first:
//					ChildViewHolder(makeView(documents:),
//					state: clientCardState.list.documents)
//				)
//		)
	}
}

struct ClientCardChildReducer<T: Equatable> {
	let reducer = Reducer<ClientCardChildState<T>, GotClientListAction<T>, ClientsEnvironment> { state, action, _ in
		switch action {
		case .gotResult(let result):
			switch result {
			case .failure(let error):
				state.loadingState = .gotError
			case .success(let success):
				state.loadingState = .gotSuccess
				state.state = success
			}
		}
		return .none
	}
}

public struct ClientCardListState: Equatable {
	var appointments: AppointmentsListState
	var details: PatientDetailsClientCardState
	var photos: ClientCardChildState<[SavedPhoto]>
	var financials: ClientCardChildState<[Financial]>
	var treatmentNotes: ClientCardChildState<[FormData]>
	var prescriptions: ClientCardChildState<[FormData]>
	var documents: DocumentsListState
	var communications: ClientCardChildState<[Communication]>
	var consents: ClientCardChildState<[FormData]>
	var alerts: ClientCardChildState<[Model.Alert]>
	var notes: ClientCardChildState<[Note]>

	init() {
		self.appointments = AppointmentsListState(
			state: ClientCardChildState.init(state: [])
		)
		self.details = PatientDetailsClientCardState(state: ClientCardChildState.init(state: PatientDetails.mock))
		self.photos = ClientCardChildState.init(state: [])
		self.financials = ClientCardChildState.init(state: [])
		self.treatmentNotes = ClientCardChildState.init(state: [])
		self.prescriptions = ClientCardChildState.init(state: [])
		self.documents = DocumentsListState(state:
		ClientCardChildState.init(state: []))
		self.communications = ClientCardChildState.init(state: [])
		self.consents = ClientCardChildState.init(state: [])
		self.alerts = ClientCardChildState.init(state: [])
		self.notes = ClientCardChildState.init(state: [])
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
	case photos(GotClientListAction<[SavedPhoto]>)
	case financials(GotClientListAction<[Financial]>)
	case treatmentNotes(GotClientListAction<[FormData]>)
	case prescriptions(GotClientListAction<[FormData]>)
	case documents(DocumentsListAction)
	case communications(GotClientListAction<[Communication]>)
	case consents(GotClientListAction<[FormData]>)
	case alerts(GotClientListAction<[Model.Alert]>)
	case notes(GotClientListAction<[Note]>)
}

let clientCardListReducer: Reducer<ClientCardListState, ClientCardChildAction, ClientsEnvironment> = Reducer.combine(
	appointmentsListReducer.pullback(
		state: \ClientCardListState.appointments,
		action: /ClientCardChildAction.appointments,
		environment: { $0 }
	),
	ClientCardChildReducer<[SavedPhoto]>().reducer.pullback(
		state: \ClientCardListState.photos,
		action: /ClientCardChildAction.photos,
		environment: { $0 }
	),
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
	ClientCardChildReducer<[FormData]>().reducer.pullback(
		state: \ClientCardListState.treatmentNotes,
		action: /ClientCardChildAction.treatmentNotes,
		environment: { $0 }
	),
	ClientCardChildReducer<[FormData]>().reducer.pullback(
		state: \ClientCardListState.prescriptions,
		action: /ClientCardChildAction.prescriptions,
		environment: { $0 }
	),
	ClientCardChildReducer<[Document]>().reducer.pullback(
		state: \ClientCardListState.documents.state,
		action: /ClientCardChildAction.documents..DocumentsListAction.action,
		environment: { $0 }
	),
	ClientCardChildReducer<[Communication]>().reducer.pullback(
		state: \ClientCardListState.communications,
		action: /ClientCardChildAction.communications,
		environment: { $0 }
	),
	ClientCardChildReducer<[FormData]>().reducer.pullback(
		state: \ClientCardListState.consents,
		action: /ClientCardChildAction.consents,
		environment: { $0 }
	),
	ClientCardChildReducer<[Model.Alert]>().reducer.pullback(
		state: \ClientCardListState.alerts,
		action: /ClientCardChildAction.alerts,
		environment: { $0 }
	),
	ClientCardChildReducer<[Note]>().reducer.pullback(
		state: \ClientCardListState.notes,
		action: /ClientCardChildAction.notes,
		environment: { $0 }
	)
)
