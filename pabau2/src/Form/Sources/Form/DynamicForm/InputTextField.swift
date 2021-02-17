import SwiftUI
import ComposableArchitecture
import Model
import SharedComponents

struct InputTextField: View {
	let store: Store<String, TextChangeAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			TextField("", text: viewStore.binding(get: { $0 }, send: { .textChange($0) }))
				.textFieldStyle(RoundedBorderTextFieldStyle())
		}
	}
}
