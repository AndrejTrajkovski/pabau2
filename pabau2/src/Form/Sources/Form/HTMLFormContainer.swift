import Model
import ComposableArchitecture
import Util
import SwiftUI
import SharedComponents
import ToastAlert

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
            return env.formAPI.save(form: form, clientId: state.clientId, pathwayStep: state.pathwayIdStepId)
				.receive(on: DispatchQueue.main)
				.catchToEffect()
				.map(HTMLFormAction.gotPOSTResponse)
		case .gotPOSTResponse(let result):
			switch result {
			case .success:
				state.postLoadingState = .gotSuccess
				state.status = .complete
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
			state.getLoadingState = .loading
			return env.formAPI.getForm(templateId: state.templateId,
									   entryId: state.filledFormId)
				.catchToEffect()
				.map(HTMLFormAction.gotForm)
				.receive(on: DispatchQueue.main)
				.eraseToEffect()
			
		case .rows(.rows(idx: let idx, action: let action)):
			break
        case .skipStep:
            if let pathwayIdStepId = state.pathwayIdStepId {
                return env.formAPI.skipStep(pathwayIdStepId)
                    .catchToEffect()
                    .map(HTMLFormAction.gotSkipResponse)
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
            } else {
                return .none
            }
        case .gotSkipResponse(let statusResult):
            switch statusResult {
            case .success(let status):
                state.status = status
            case .failure(let error):
                state.skipToast = ToastState(mode: .alert,
                                             type: .error(.red),
                                             title: "Failed to skip step")
                return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                    .map { _ in HTMLFormAction.hideToast }
            }
        case .hideToast:
            state.skipToast = nil
        }
        return .none
    }
)

public struct HTMLFormParentState: Equatable, Identifiable {
    
	public init(formTemplateName: String,
				formType: FormType,
				stepStatus: StepStatus,
				formEntryID: FilledFormData.ID?,
				formTemplateId: HTMLForm.ID,
				clientId: Client.ID,
                pathwayIdStepId: PathwayIdStepId,
                stepType: StepType) {
		self.templateId = formTemplateId
		self.templateName = formTemplateName
		self.type = formType
		self.clientId = clientId
		self.filledFormId = formEntryID
		self.status = stepStatus
		self.getLoadingState = .initial
		self.postLoadingState = .initial
		self.saveFailureAlert = nil
        self.pathwayIdStepId = pathwayIdStepId
        self.stepType = stepType
	}
	
	public init(templateId: HTMLForm.ID,
				templateName: String,
				type: FormType,
				clientId: Client.ID,
				filledFormId: FilledFormData.ID?,
				status: StepStatus
	) {
		self.templateId = templateId
		self.templateName = templateName
		self.type = type
		self.clientId = clientId
		self.filledFormId = filledFormId
		self.status = status
		self.getLoadingState = .initial
		self.postLoadingState = .initial
		self.saveFailureAlert = nil
        self.stepType = nil
	}
	
	public init(formData: FilledFormData,
				clientId: Client.ID,
				getLoadingState: LoadingState) {
		self.templateId = formData.templateId
		self.templateName = formData.templateName
		self.type = formData.templateType
		self.form = nil
		self.getLoadingState = getLoadingState
		self.status = .pending
		self.filledFormId = formData.treatmentId
		self.clientId = clientId
		self.postLoadingState = .initial
        self.stepType = nil
	}
	
	public init(info: FormTemplateInfo,
				clientId: Client.ID,
				getLoadingState: LoadingState) {
		self.templateId = info.id
		self.templateName = info.name
		self.type = info.type
		self.form = nil
		self.getLoadingState = getLoadingState
		self.status = .pending
		self.filledFormId = nil
		self.clientId = clientId
		self.postLoadingState = .initial
        self.stepType = nil
	}
	
	public var id: HTMLForm.ID { templateId }
	
	public let templateId: HTMLForm.ID
	public let templateName: String
	public let type: FormType
	public let clientId: Client.ID
	public let filledFormId: FilledFormData.ID?
	public var form: HTMLForm?
	public var getLoadingState: LoadingState
	public var postLoadingState: LoadingState
	public var status: StepStatus
	public var saveFailureAlert: AlertState<HTMLFormAction>?
    public var pathwayIdStepId: PathwayIdStepId?
    public var skipToast: ToastState<HTMLFormAction>?
    public let stepType: StepType?
}

public enum HTMLFormAction: Equatable {
    case gotSkipResponse(Result<StepStatus, RequestError>)
    case skipStep
	case gotPOSTResponse(Result<FilledFormData.ID, RequestError>)
	case gotForm(Result<HTMLForm, RequestError>)
	case getFormError(ErrorViewAction)
	case rows(HTMLRowsAction)
	case saveAlertCanceled
    case hideToast
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
        Group {
            switch viewStore.state {
            case .getting:
                LoadingView.init(title: "Loading", bindingIsShowing: .constant(true), content: { Spacer() })
            case .saving:
                LoadingView.init(title: "Saving", bindingIsShowing: .constant(true), content: { Spacer() })
            case .loaded:
                IfLetStore(store.scope(state: { $0.form }, action: { .rows($0) }),
                           then: { HTMLFormView(store: $0, isCheckingDetails: false) },
                           else: IfLetErrorView(store: store.scope(state: { $0.getLoadingState },
                                                                   action: { .getFormError($0) }))
                ).alert(store.scope(state: \.saveFailureAlert), dismiss: HTMLFormAction.saveAlertCanceled)
            case .initial:
                EmptyView()
            }
        }.toast(store: store.scope(state: { $0.skipToast }))
	}
}
