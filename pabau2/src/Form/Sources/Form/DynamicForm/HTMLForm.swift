import Model
import SwiftUI
import ComposableArchitecture
import Util

public struct HTMLFormView<Footer: View>: View {

	let isCheckingDetails: Bool
	let store: Store<HTMLForm, HTMLRowsAction>
    let footer: () -> Footer?
	public init(store: Store<HTMLForm, HTMLRowsAction>,
				isCheckingDetails: Bool = false,
                @ViewBuilder footer: @escaping () -> Footer?) {
		self.store = store
		self.isCheckingDetails = isCheckingDetails
        self.footer = footer
	}

	public var body: some View {
		VStack {
			HTMLFormTitle(store: store.scope(state: { $0.name }).actionless)
			ScrollView {
				LazyVStack {
					ForEachStore(store.scope(state: { $0.formStructure },
											 action: { HTMLRowsAction.rows(idx: $0, action: $1) }),
								 content: { localStore in
									FormSectionField(store: localStore,
													 isCheckingDetails: isCheckingDetails)
								 }
					)
				}
			}
            if let myFooter = footer() {
                myFooter
            }
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
