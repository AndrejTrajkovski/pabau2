import Model
import SwiftUI
import ComposableArchitecture
import Util

public let formTemplateReducer: Reducer<FormTemplate, FormTemplateAction, FormEnvironment> = .combine(
	.init { state, action, env in
		switch action {
		case .complete:
			break
		case .fields:
			break
		}
		return .none
	},
	cssFieldReducer.forEach(
		state: \FormTemplate.formStructure.formStructure,
		action: /FormTemplateAction.fields(idx:action:),
		environment: { $0 }
	)
)

public enum FormTemplateAction {
	case fields(idx: Int, action: CSSClassAction)
	case complete(CompleteBtnAction)
}

public struct ListDynamicForm: View {

	let store: Store<FormTemplate, FormTemplateAction>

	public init(store: Store<FormTemplate, FormTemplateAction>) {
		self.store = store
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}
	
	public var body: some View {
		print("ListDynamicForm body")
		return VStack {
			List {
				DynamicForm(store: store, isCheckingDetails: false)
			}
			CompleteButton(store: store.scope(state: { $0 },
											  action: { .complete($0) })
			)
		}
	}
}

struct DynamicForm: View {

	let isCheckingDetails: Bool
	let store: Store<FormTemplate, FormTemplateAction>
	@ObservedObject var viewStore: ViewStore<String, Never>
	init(store: Store<FormTemplate, FormTemplateAction>,
		 isCheckingDetails: Bool) {
		self.store = store
		self.isCheckingDetails = isCheckingDetails
		self.viewStore = ViewStore(store.scope(state: { $0.name }).actionless)
	}

	public var body: some View {
		VStack {
			Text(self.viewStore.state).font(.title)
			ForEachStore(store.scope(state: { $0.formStructure.formStructure },
									 action: FormTemplateAction.fields(idx:action:)),
						 content: { store in
							FormSectionField(store: store,
											 isCheckingDetails: isCheckingDetails)
						 }
			)
		}
	}
}
