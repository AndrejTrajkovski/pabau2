import SwiftUI
import Model
import ComposableArchitecture

struct NotesList: ClientCardChild {
	let store: Store<ClientCardChildState<[Note]>, GotClientListAction<[Note]>>
	var body: some View {
		WithViewStore(store) { viewStore in
			List {
				ForEach (viewStore.state.state.indices, id: \.self) { idx in
					NoteRow(note: viewStore.state.state[idx])
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
