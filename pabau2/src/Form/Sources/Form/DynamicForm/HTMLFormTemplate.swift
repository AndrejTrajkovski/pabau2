import Model
import SwiftUI
import ComposableArchitecture
import Util

public let htmlFormReducer: Reducer<HTMLFormTemplate, HTMLFormAction, FormEnvironment> = .combine(
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
		state: \HTMLFormTemplate.formStructure.formStructure,
		action: /HTMLFormAction.fields(idx:action:),
		environment: { $0 }
	)
)

public enum HTMLFormAction {
	case fields(idx: Int, action: CSSClassAction)
	case complete(CompleteBtnAction)
	//idea:
//	case requests(JourneyFormRequestsAction<HTMLForm>)
}

public struct ListHTMLForm: View {
	
	let store: Store<HTMLFormTemplate, HTMLFormAction>
	
	public init(store: Store<HTMLFormTemplate, HTMLFormAction>) {
		self.store = store
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}
	
	public var body: some View {
		print("ListHTMLForm body")
		return VStack {
			List {
				HTMLFormView(store: store, isCheckingDetails: false)
			}
			CompleteButton(store: store.scope(state: { $0 },
											  action: { .complete($0) })
			)
		}
	}
}

struct HTMLFormView: View {
	
	let isCheckingDetails: Bool
	let store: Store<HTMLFormTemplate, HTMLFormAction>
	@ObservedObject var viewStore: ViewStore<String, Never>
	init(store: Store<HTMLFormTemplate, HTMLFormAction>,
		 isCheckingDetails: Bool) {
		self.store = store
		self.isCheckingDetails = isCheckingDetails
		self.viewStore = ViewStore(store.scope(state: { $0.name }).actionless)
	}
	
	public var body: some View {
		VStack {
			Text(self.viewStore.state).font(.title)
			ForEachStore(store.scope(state: { $0.formStructure.formStructure },
									 action: HTMLFormAction.fields(idx:action:)),
						 content: { store in
							FormSectionField(store: store,
											 isCheckingDetails: isCheckingDetails)
						 }
			)
		}
	}
}
