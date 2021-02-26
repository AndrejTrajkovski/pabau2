import Model
import ComposableArchitecture
import Util
import SwiftUI

public let htmlFormParentReducer: Reducer<HTMLFormParentState, HTMLFormAction, FormEnvironment> = .combine(
//	cssFieldReducer.optional.forEach(
//		state: \HTMLFormParentState.form.formStructure,
//		action: /HTMLFormAction.rows(idx:action:),
//		environment: { $0 }
//	),
	.init { state, action, env in
		switch action {
		case .gotForm(let result):
			switch result {
			case .success(let value):
				state.form = value
				state.getLoadingState = .gotSuccess
			case .failure(let error):
				state.getLoadingState = .gotError(error)
				print(error)
			}
		case .complete:
			guard let form = state.form else { break }
			return env.formAPI.save(form: form, clientId: state.clientId)
				.receive(on: DispatchQueue.main)
				.catchToEffect()
				.map(HTMLFormAction.gotPOSTResponse)
		case .gotPOSTResponse(let result):
			print(result)
			state.isComplete = true
		case .rows(idx: let idx, action: let action):
			break
		case .getFormError(.retry):
			break
		}
		return .none
	}
)

public struct HTMLFormParentState: Equatable, Identifiable {

	public var id: HTMLForm.ID { info.id }

	public init(formData: FilledFormData,
				clientId: Client.ID) {
		self.info = formData.templateInfo
		self.form = nil
		self.getLoadingState = .initial
		self.isComplete = false
		self.filledFormId = formData.treatmentId
		self.clientId = clientId
		self.postLoadingState = .initial
	}

	public init(info: FormTemplateInfo,
				clientId: Client.ID) {
		self.info = info
		self.form = nil
		self.getLoadingState = .initial
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
//	public var saveAlert: AlertState<HTMLFormAction>
}

public enum HTMLFormAction: Equatable {
	case gotPOSTResponse(Result<VoidAPIResponse, RequestError>)
	case gotForm(Result<HTMLForm, RequestError>)
	case getFormError(ErrorViewAction)
	case complete(CompleteBtnAction)
	case rows(idx: Int, action: CSSClassAction)
}

public struct HTMLFormParent: View {
	public init(store: Store<HTMLFormParentState, HTMLFormAction>) {
		self.store = store
	}

	let store: Store<HTMLFormParentState, HTMLFormAction>
	public var body: some View {
			IfLetStore(store.scope(state: { $0.form }),
					   then: { HTMLFormView(store: $0, isCheckingDetails: false) },
					   else: LoadingStateView(store: store.scope(state: { $0.getLoadingState },
																 action: { .getFormError($0) }))
			)
	}
}

struct LoadingStateView: View {
	let store: Store<LoadingState, ErrorViewAction>
	
	var body: some View {
		IfLetStore(store.scope(state: { state in
			return state == .loading
		}),
		then: {
			_ in LoadingView.init(title: "Loading", bindingIsShowing: .constant(true), content: { Spacer() })
		},
		else:
			IfLetStore(store.scope(state: { state in
				extract(case: LoadingState.gotError, from: state)
			}),
				then: ErrorView.init(store:)
			)
		)
	}
}

public enum ErrorViewAction {
	case retry
}

struct ErrorView: View {
	let store: Store<RequestError, ErrorViewAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				Text(viewStore.state.localizedDescription).foregroundColor(.red)
				Button("Retry", action: { viewStore.send(.retry) })
			}
		}
	}
}
