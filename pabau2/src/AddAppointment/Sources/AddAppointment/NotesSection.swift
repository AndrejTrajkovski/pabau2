import SwiftUI
import ComposableArchitecture
import AddEventControls

struct NotesSection: View {
	let store: Store<String, TextChangeAction>
	public var body: some View {
		VStack(alignment: .leading, spacing: 24.0) {
			Text("Notes").font(.semibold24)
			TitleAndTextField(title: "BOOKING NOTE",
							  tfLabel: "Add a booking note",
							  store: self.store)
		}
	}
}
