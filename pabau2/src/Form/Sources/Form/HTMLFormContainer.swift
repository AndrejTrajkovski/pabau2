import Model
import ComposableArchitecture
import Util
import SwiftUI

public let htmlFormParentReducer: Reducer<HTMLFormParentState, HTMLFormParentAction, FormEnvironment> = .combine(
	htmlFormReducer.optional.pullback(
		state: \HTMLFormParentState.form,
		action: /HTMLFormParentAction.form,
		environment: { $0 }),
	.init { state, action, env in
		switch action {
		case .gotForm(let result):
			switch result {
			case .success(let value):
				state.form = value
				state.loadingState = .gotSuccess
			case .failure(let error):
				state.loadingState = .gotError(error)
			}
		case .form(.complete):
			guard let form = state.form else { break }
			return env.formAPI.save(form: form, clientId: state.clientId)
				.receive(on: DispatchQueue.main)
				.catchToEffect()
				.map(HTMLFormParentAction.gotPOSTResponse)
		case .gotPOSTResponse(let result):
			print(result)
			state.isComplete = true
		case .form(.rows(idx: let idx, action: let action)):
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
		self.loadingState = .initial
		self.isComplete = false
		self.filledFormId = formData.treatmentId
		self.clientId = clientId
	}

	public init(info: FormTemplateInfo,
				clientId: Client.ID) {
		self.info = info
		self.form = nil
		self.loadingState = .initial
		self.isComplete = false
		self.filledFormId = nil
		self.clientId = clientId
	}

	public let clientId: Client.ID
	public let filledFormId: FilledFormData.ID?
	public let info: FormTemplateInfo
	public var form: HTMLForm?
	public var loadingState: LoadingState
	public var isComplete: Bool
}

public enum HTMLFormParentAction: Equatable {
	case gotPOSTResponse(Result<VoidAPIResponse, RequestError>)
	case gotForm(Result<HTMLForm, RequestError>)
	case form(HTMLFormAction)
}

public struct HTMLFormParent: View {
	public init(store: Store<HTMLFormParentState, HTMLFormParentAction>) {
		self.store = store
	}

	let store: Store<HTMLFormParentState, HTMLFormParentAction>
	public var body: some View {
		IfLetStore(store.scope(state: { $0.form },
							   action: { .form($0) }),
				   then: { HTMLFormViewCompleteBtn(store: $0) },
				   else: LoadingView.init(title: "Loading", bindingIsShowing: .constant(true), content: { Spacer()})
		)
	}
}
