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
			print("got form: \(result)")
			switch result {
			case .success(let value):
				state.form = value
				state.loadingState = .gotSuccess
			case .failure(let error):
				state.loadingState = .gotError(error)
			}
		case .form(.complete):
			state.isComplete = true
		case .form(.rows(idx: let idx, action: let action)):
			break
		}
		return .none
	}
)

public struct HTMLFormParentState: Equatable, Identifiable {
	public var id: HTMLForm.ID { info.id }

	public init(info: HTMLFormInfo) {
		self.info = info
		self.form = nil
		self.loadingState = .initial
		self.isComplete = false
	}

	public let info: HTMLFormInfo
	public var form: HTMLForm?
	public var loadingState: LoadingState
	public var isComplete: Bool
}

public enum HTMLFormParentAction: Equatable {
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
