import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

struct CheckPatientForm: View {
	let store: Store<CheckPatient, Never>
	@ObservedObject var viewStore: ViewStore<CheckPatient, Never>

	init(store: Store<CheckPatient, Never>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		print("CheckPatientForm body")
		return ScrollView {
			VStack {
				PatientDetailsForm(store: Store.init(initialState: viewStore.state.clientBuilder,
													 reducer: Reducer.empty,
													 environment: { })
				)
				ForEach(viewStore.patForms.indices, id: \.self ) { index in
					HTMLFormView(
						store: Store(initialState: viewStore.patForms[index],
									 reducer: Reducer.empty,
									 environment: { }),
						isCheckingDetails: true
					)
				}
			}.disabled(true)
		}
	}
}
