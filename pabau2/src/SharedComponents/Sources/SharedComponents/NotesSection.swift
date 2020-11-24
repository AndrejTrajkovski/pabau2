import SwiftUI
import ComposableArchitecture

public struct NotesSection: View {
	let store: Store<String, TextChangeAction>
	
	public init (store: Store<String, TextChangeAction>) {
		self.store = store
	}
	
	public var body: some View {
		TitleAndTextField(title: "BOOKING NOTE",
						  tfLabel: "Add a booking note",
						  store: self.store)
			.wrapAsSection(title: "Notes")
	}
}
