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

public struct HTMLFormView: View {

	let isCheckingDetails: Bool
	let store: Store<HTMLForm, HTMLFormAction>
	public init(store: Store<HTMLForm, HTMLFormAction>,
				isCheckingDetails: Bool = false) {
		self.store = store
		self.isCheckingDetails = isCheckingDetails
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}

	public var body: some View {
		print("HTMLForm")
		return ScrollView {
			LazyVStack {
				ForEachStore(store.scope(state: { $0.formStructure },
										 action: { HTMLFormAction.rows(idx: $0, action: $1) }),
							 content: { localStore in
								FormSectionField(store: localStore,
												 isCheckingDetails: isCheckingDetails)
							 }
				).id(UUID())
				CompleteButton(store: store.scope(state: { $0 },
												  action: { .complete($0) })
				)
			}
		}
	}
}
