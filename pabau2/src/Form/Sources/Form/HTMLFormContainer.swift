import Model
import ComposableArchitecture
import Util
import SwiftUI

public let htmlFormParentReducer: Reducer<HTMLFormParentState, HTMLFormAction, FormEnvironment> = .combine(
	formReducer.optional().pullback(
		state: \HTMLFormParentState.form,
		action: /HTMLFormAction.rows,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .gotForm(let result):
			print("enters here")
			switch result {
			case .success(let value):
				state.form = value
				state.getLoadingState = .gotSuccess
			case .failure(let error):
				state.getLoadingState = .gotError(error)
				print(error)
			}
		case .rows(.complete):
			guard let form = state.form else { break }
			state.postLoadingState = .loading
			return env.formAPI.save(form: form, clientId: state.clientId)
				.receive(on: DispatchQueue.main)
				.catchToEffect()
				.map(HTMLFormAction.gotPOSTResponse)
		case .gotPOSTResponse(let result):
			switch result {
			case .success:
				state.postLoadingState = .gotSuccess
				state.isComplete = true
			case .failure(let error):
				state.postLoadingState = .gotError(error)
				state.saveFailureAlert = AlertState(
					title: TextState("Error Saving Form"),
					message: TextState(error.description),
					dismissButton: .default(TextState("OK"))
				)
			}
		case .saveAlertCanceled:
			state.saveFailureAlert = nil
		case .getFormError(.retry):
			break
		case .rows(.rows(idx: let idx, action: let action)):
			break
		}
		return .none
	}
)

public struct HTMLFormParentState: Equatable, Identifiable {

	public var id: HTMLForm.ID { info.id }

	public init(formData: FilledFormData,
				clientId: Client.ID,
				getLoadingState: LoadingState) {
		self.info = formData.templateInfo
		self.form = nil
		self.getLoadingState = getLoadingState
		self.isComplete = false
		self.filledFormId = formData.treatmentId
		self.clientId = clientId
		self.postLoadingState = .initial
	}

	public init(info: FormTemplateInfo,
				clientId: Client.ID,
				getLoadingState: LoadingState) {
		self.info = info
		self.form = nil
		self.getLoadingState = getLoadingState
		self.isComplete = false
		self.filledFormId = nil
		self.clientId = clientId
		self.postLoadingState = .initial
	}

	public let clientId: Client.ID
	public let filledFormId: FilledFormData.ID?
	public let info: FormTemplateInfo
	public var form: HTMLForm?
	public var getLoadingState: LoadingState
	public var postLoadingState: LoadingState
	public var isComplete: Bool
	public var saveFailureAlert: AlertState<HTMLFormAction>?
}

public enum HTMLFormAction: Equatable {
	case gotPOSTResponse(Result<FilledFormData.ID, RequestError>)
	case gotForm(Result<HTMLForm, RequestError>)
	case getFormError(ErrorViewAction)
	case rows(HTMLRowsAction)
	case saveAlertCanceled
}

public struct HTMLFormParent: View {
	public init(store: Store<HTMLFormParentState, HTMLFormAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}

	enum State: Equatable {
		case getting
		case saving
		case loaded
		case initial
		init(state: HTMLFormParentState) {
			if state.getLoadingState == .loading {
				self = .getting
			} else if state.postLoadingState == .loading {
				self = .saving
			} else if case LoadingState.gotError(_) = state.getLoadingState {
				self = .loaded
			} else if case LoadingState.gotSuccess = state.getLoadingState {
				self = .loaded
			} else {
				self = .initial
			}
		}
	}

	let store: Store<HTMLFormParentState, HTMLFormAction>
	@ObservedObject var viewStore: ViewStore<State, HTMLFormAction>

	public var body: some View {
		switch viewStore.state {
		case .getting:
			LoadingView.init(title: "Loading", bindingIsShowing: .constant(true), content: { Spacer() })
		case .saving:
			LoadingView.init(title: "Saving", bindingIsShowing: .constant(true), content: { Spacer() })
		case .loaded:
			IfLetStore(store.scope(state: { $0.form }, action: { .rows($0) }),
					   then: { HTMLFormView(store: $0, isCheckingDetails: false) },
					   else: Loading(store: store.scope(state: { $0.getLoadingState },
																 action: { .getFormError($0) }))
			).alert(store.scope(state: \.saveFailureAlert), dismiss: HTMLFormAction.saveAlertCanceled)
		case .initial:
			EmptyView()
		}
	}
}

struct Loading: View {
	let store: Store<LoadingState, ErrorViewAction>

	var body: some View {
		IfLetStore(store.scope(state: { state in
			extract(case: LoadingState.gotError, from: state)
		}),
			then: ErrorRetry.init(store:)
		)
	}
}

public enum ErrorViewAction {
	case retry
}

struct ErrorRetry: View {
	let store: Store<RequestError, ErrorViewAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				PlainError(store: store.actionless)
				Button("Retry", action: { viewStore.send(.retry) })
			}
		}
	}
}

struct PlainError: View {
	let store: Store<RequestError, Never>
	var body: some View {
		WithViewStore(store) { viewStore in
			Text(viewStore.state.description).foregroundColor(.red)
		}
	}
}
