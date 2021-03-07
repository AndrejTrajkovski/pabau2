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
				PatientDetailsForm(store: Store.init(initialState: viewStore.state.patDetails,
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

func viewModels(_ patientDetails: ClientBuilder) -> [[TextAndTextViewVM]] {
	[
		[
			TextAndTextViewVM(
				.constant(patientDetails.salutation ?? ""),
				Texts.salutation),
			TextAndTextViewVM(
				.constant(patientDetails.firstName ?? ""),
				Texts.firstName),
			TextAndTextViewVM(
				.constant(patientDetails.lastName ?? ""),
				Texts.lastName)
		],
		[
			TextAndTextViewVM(
                .constant(patientDetails.dateOfBirth),
				Texts.dob),
			TextAndTextViewVM(
				.constant(patientDetails.phone ?? ""),
				Texts.phone),
			TextAndTextViewVM(
				.constant(patientDetails.mobile ?? ""),
				Texts.cellPhone)
		],
		[
			TextAndTextViewVM(
				.constant(patientDetails.email ?? ""),
				Texts.email),
			TextAndTextViewVM(
				.constant(patientDetails.mailingStreet ?? ""),
				Texts.addressLine1),
			TextAndTextViewVM(
				.constant(patientDetails.otherStreet ?? ""),
				Texts.addressLine2)
		],
		[
			TextAndTextViewVM(
				.constant(patientDetails.mailingPostal ?? ""),
				Texts.postCode),
			TextAndTextViewVM(
				.constant(patientDetails.mailingCity ?? ""),
				Texts.city),
			TextAndTextViewVM(
				.constant(patientDetails.mailingCounty ?? ""),
				Texts.county)
		],
		[
			TextAndTextViewVM(
				.constant(patientDetails.mailingCountry ?? ""),
				Texts.country),
			TextAndTextViewVM(
				.constant(patientDetails.howDidYouHear ?? ""),
				Texts.howDidUHear)
		]
	]
}
