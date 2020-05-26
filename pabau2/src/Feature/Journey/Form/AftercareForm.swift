import SwiftUI
import ComposableArchitecture

public enum AftercareAction: Equatable {
	
}

struct AftercareForm: View {

	let store: Store<Aftercare, AftercareAction>
	@ObservedObject var viewStore: ViewStore<Aftercare, AftercareAction>

	var body: some View {
		Text("Aftercare")
	}
}
