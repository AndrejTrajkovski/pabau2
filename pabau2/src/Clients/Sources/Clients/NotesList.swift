import SwiftUI
import Model
import ComposableArchitecture
import Util

let clientNotesListReducer: Reducer<NotesListState, NotesListAction, ClientsEnvironment> = Reducer.combine(
    ClientCardChildReducer<[Note]>().reducer.pullback(
        state: \NotesListState.childState,
        action: /NotesListAction.action,
        environment: { $0 }
    ),
    .init { state, action, env in
        switch action {
        case .saveNote(let content):
            state.showAlert = false
            return env.apiClient
                .addNote(clientId: state.client.id, note: content)
                .catchToEffect()
                .receive(on: DispatchQueue.main)
                .map { .onResponseSave(.gotResult($0)) }
                .eraseToEffect()
        case .didTouchAdd:
            state.showAlert = true
        case .dismissNote:
            state.showAlert = false
        case .onResponseSave(let result):
            switch result {
            case .gotResult(.success(let note)):
                state.childState.state.append(note)
            default:
                break
            }
        default: break
        }
        return .none
    }
)

public struct NotesListState: ClientCardChildParentState {
    var client: Client
    var childState: ClientCardChildState<[Note]>
    var showAlert: Bool = false
}

public enum NotesListAction: ClientCardChildParentAction {
    case action(GotClientListAction<[Note]>)
    case onResponseSave(GotClientListAction<Note>)
    case saveNote(String)
    case didTouchAdd
    case dismissNote
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
            .navigationTitle("Notes")
            .alert(isPresented: viewStore.binding(get: { $0.showAlert }, send: NotesListAction.didTouchAdd),
                   TextAlertView(title: "Add Note", placeholder: "Enter Note",
                             action: { action in
                                switch action {
                                case .add(let text):
                                    viewStore.send(.saveNote(text))
                                case .dismiss:
                                    viewStore.send(.dismissNote)
                                }
                             }
                   )
            )
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
