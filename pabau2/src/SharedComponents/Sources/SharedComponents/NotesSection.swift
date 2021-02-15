import SwiftUI
import ComposableArchitecture

public struct NotesSection: View {
    let title: String
    let tfLabel: String
	let store: Store<String, TextChangeAction>

	public init(
        title: String,
        tfLabel: String,
        store: Store<String, TextChangeAction>
    ) {
        self.title = title
        self.tfLabel = tfLabel
		self.store = store
	}

    
	public var body: some View {
		TitleAndTextField(
            title: title,
            tfLabel: tfLabel,
            store: self.store
        ).wrapAsSection(title: "Notes")
	}
}
