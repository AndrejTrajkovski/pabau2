import SwiftUI
import ComposableArchitecture
import Model
import Combine
import Util

protocol ClientCardChild: View {
	associatedtype State: Equatable
	var state: State { get set }
	init(state: State)
}

struct ChildViewHolder<T: Equatable, Child: ClientCardChild>: View
where T == Child.State {
	let state: ClientCardChildState<T>
	let child: Child.Type
	init(child: Child.Type,
			 state: ClientCardChildState<T>) {
		self.child = child
		self.state = state
	}
	var body: some View {
		ViewBuilder.buildBlock(
			(state.loadingState == .loading) ?
				ViewBuilder.buildEither(second: Text("Loading"))
				:
				ViewBuilder.buildEither(first: Child.init(state:state.state)
			)
		)
	}
}

struct ParentClientCardChildView: View {
	let clientCardState: ClientCardState
	var body: some View {
		if clientCardState.activeItem == .appointments {
			return AnyView(ChildViewHolder(child: AppointmentsList.self,
																		 state: clientCardState.list.appointments))
		} else {
			return AnyView(ChildViewHolder(child:DocumentsList.self,
																		 state: clientCardState.list.documents))
		}
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
	var appointments: ClientCardChildState<[Appointment]>
	var details: ClientCardChildState<PatientDetails>
	var photos: ClientCardChildState<[SavedPhoto]>
	var financials: ClientCardChildState<[Financial]>
	var treatmentNotes: ClientCardChildState<[FormData]>
	var prescriptions: ClientCardChildState<[FormData]>
	var documents: ClientCardChildState<[Document]>
	var communications: ClientCardChildState<[Communication]>
	var consents: ClientCardChildState<[FormData]>
	var alerts: ClientCardChildState<[Model.Alert]>
	var notes: ClientCardChildState<[Note]>

	init() {
		self.appointments = ClientCardChildState.init(state: [])
		self.details = ClientCardChildState.init(state: PatientDetails.mock)
		self.photos = ClientCardChildState.init(state: [])
		self.financials = ClientCardChildState.init(state: [])
		self.treatmentNotes = ClientCardChildState.init(state: [])
		self.prescriptions = ClientCardChildState.init(state: [])
		self.documents = ClientCardChildState.init(state: [])
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
	case appointments(GotClientListAction<[Appointment]>)
	case details(GotClientListAction<PatientDetails>)
	case photos(GotClientListAction<[SavedPhoto]>)
	case financials(GotClientListAction<[Financial]>)
	case treatmentNotes(GotClientListAction<[FormData]>)
	case prescriptions(GotClientListAction<[FormData]>)
	case documents(GotClientListAction<[Document]>)
	case communications(GotClientListAction<[Communication]>)
	case consents(GotClientListAction<[FormData]>)
	case alerts(GotClientListAction<[Model.Alert]>)
	case notes(GotClientListAction<[Note]>)
}

let clientCardListReducer: Reducer<ClientCardListState, ClientCardChildAction, ClientsEnvironment> = Reducer.combine(
	ClientCardChildReducer<[Appointment]>().reducer.pullback(
		state: \ClientCardListState.appointments,
		action: /ClientCardChildAction.appointments,
		environment: { $0 }
	),
	ClientCardChildReducer<PatientDetails>().reducer.pullback(
		state: \ClientCardListState.details,
		action: /ClientCardChildAction.details,
		environment: { $0 }
	),
	ClientCardChildReducer<[SavedPhoto]>().reducer.pullback(
		state: \ClientCardListState.photos,
		action: /ClientCardChildAction.photos,
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
		state: \ClientCardListState.documents,
		action: /ClientCardChildAction.documents,
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
