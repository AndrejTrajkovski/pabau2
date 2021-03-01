import Model
import SwiftUI
import ComposableArchitecture
import Util

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
		VStack {
			HTMLFormTitle(store: store.scope(state: { $0.templateInfo.name }).actionless)
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
			CompleteButton(store: store.scope(state: { $0 },
											  action: { .complete($0) })
			)
		}
	}
}

public struct HTMLFormTitle: View {
	let store: Store<String, Never>
	public var body: some View {
		WithViewStore(store) { viewStore in
			Text(viewStore.state).font(.title)
		}
	}
}
