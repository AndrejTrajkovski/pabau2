import SwiftUI
import Model
import ComposableArchitecture

private func asset(_ format: DocumentExtension) -> String {
	return "ico-clients-documents-" + format.rawValue
}

struct DocumentsListState: ClientCardChildParentState, Equatable {
	typealias T = [Document]
	var childState: ClientCardChildState<[Document]>
}

public enum DocumentsListAction: ClientCardChildParentAction, Equatable {
	var action: GotClientListAction<[Document]>? {
		get {
			if case .action(let localAction) = self  {
				return localAction
		} else {
			return nil
			}
		}
		set {
			if let newValue = newValue {
				self = .action(newValue)
			}
		}
	}
	case action(GotClientListAction<[Document]>)
	typealias T = [Document]
}

struct DocumentsList: ClientCardChild {
	typealias State = DocumentsListState

	typealias Action = DocumentsListAction

	var store: Store<DocumentsListState, DocumentsListAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			List {
				ForEach(viewStore.state.childState.state.indices, id: \.self) { idx in
					DocumentRow(doc: viewStore.state.childState.state[idx])
				}
			}
		}
	}
}

struct DocumentRow: View {
	let doc: Document
	var body: some View {
		ClientCardItemBaseRow(title: doc.title,
													date: doc.date,
													image: Image(asset(doc.format)))
	}
}
