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
		 ScrollView {
			VStack {
				if let clientBuilder = viewStore.state.clientBuilder {
					PatientDetailsForm(
						store: Store.init(
							initialState: clientBuilder,
							reducer: Reducer.empty,
							environment: { }
						),
						isDisabled: true
					)
				}
                ForEach(viewStore.patForms.indices, id: \.self ) { index in
                    HTMLFormView(
                        store: Store(
                            initialState: viewStore.patForms[index],
                            reducer: Reducer.empty,
                            environment: { }
                        ),
                        isCheckingDetails: true
                    )
                }
            }.disabled(true)
		}
	}
}
