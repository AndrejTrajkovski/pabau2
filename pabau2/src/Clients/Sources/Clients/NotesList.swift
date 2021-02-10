import SwiftUI
import Model
import ComposableArchitecture

let clientNotesListReducer: Reducer<NotesListState, NotesListAction, ClientsEnvironment> = Reducer.combine(
    ClientCardChildReducer<[Note]>().reducer.pullback(
        state: \NotesListState.childState,
        action: /NotesListAction.action,
        environment: { $0 }
    )
)

public struct NotesListState: ClientCardChildParentState {
    var childState: ClientCardChildState<[Note]>
}

public enum NotesListAction: ClientCardChildParentAction {
    case action(GotClientListAction<[Note]>)
    var action: GotClientListAction<[Note]>? {
        get {
            if case .action(let notes) = self {
                return notes
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
}

struct NotesList: ClientCardChild {
    let store: Store<NotesListState, NotesListAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			List {
                ForEach(viewStore.state.childState.state.indices, id: \.self) { idx in
                    NoteRow(note: viewStore.state.childState.state[idx])
				}
			}
		}
	}
}

struct NoteRow: View {
	let note: Note
	var body: some View {
		VStack(alignment: .leading) {
			TitleAndDate(title: note.content, date: note.date)
			Divider()
		}
	}
}
