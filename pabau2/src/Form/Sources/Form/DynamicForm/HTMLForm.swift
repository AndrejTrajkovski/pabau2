import Model
import SwiftUI
import ComposableArchitecture
import Util

public let htmlFormReducer: Reducer<HTMLForm, HTMLFormAction, FormEnvironment> = .combine(
	cssFieldReducer.forEach(
		state: \HTMLForm.formStructure,
		action: /HTMLFormAction.rows(idx:action:),
		environment: { $0 }
	)
)

public enum HTMLFormAction: Equatable {
	case rows(idx: Int, action: CSSClassAction)
	case complete(CompleteBtnAction)
	//idea:
//	case requests(JourneyFormRequestsAction<HTMLForm>)
}

public struct HTMLFormViewCompleteBtn: View {

	let store: Store<HTMLForm, HTMLFormAction>
	
	public init(store: Store<HTMLForm, HTMLFormAction>) {
		self.store = store
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}
	
	public var body: some View {
		VStack {
			HTMLFormView(store: store, isCheckingDetails: false)
			CompleteButton(store: store.scope(state: { $0 },
											  action: { .complete($0) })
			)
		}
	}
}

struct HTMLFormView: View {

	let isCheckingDetails: Bool
	let store: Store<HTMLForm, HTMLFormAction>
	@ObservedObject var viewStore: ViewStore<String, Never>
	init(store: Store<HTMLForm, HTMLFormAction>,
		 isCheckingDetails: Bool) {
		self.store = store
		self.isCheckingDetails = isCheckingDetails
		self.viewStore = ViewStore(store.scope(state: { $0.templateInfo.name }).actionless)
	}
	
	public var body: some View {
		ScrollView {
			LazyVStack {
				ForEachStore(store.scope(state: { $0.formStructure },
										 action: { HTMLFormAction.rows(idx: $0, action: $1) }),
							 content: { localStore in
								FormSectionField(store: localStore,
												 isCheckingDetails: isCheckingDetails)
							 }
				)
			}
		}
	}
}
