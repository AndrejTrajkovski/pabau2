import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

struct CheckPatientForm: View {
	let didTouchDone: () -> Void
	let patDetails: PatientDetails
	let patientForms: [FormTemplate]

	var body: some View {
		print("CheckPatientForm body")
		return ScrollView {
			VStack {
				PatientDetailsTextFields(vms: viewModels(patDetails))
				Group {
					SwitchCellRaw(text: Texts.emailConfirmations,
								  value: .constant(patDetails.emailComm)
					)
					SwitchCellRaw(text: Texts.smsReminders,
								  value: .constant(patDetails.smsComm)
					)
					SwitchCellRaw(text: Texts.phone,
								  value: .constant(patDetails.phoneComm)
					)
					SwitchCellRaw(text: Texts.post,
								  value: .constant(patDetails.postComm)
					)
				}.switchesSection(title: Texts.communications)
				ForEach(patientForms.indices, id: \.self ) { index in
					DynamicForm(
						template: .constant(self.patientForms[index]),
						isCheckingDetails: true
					)
				}
			}.disabled(true)
		}
	}
}

func viewModels(_ patientDetails: PatientDetails) -> [[TextAndTextViewVM]] {
	[
		[
			TextAndTextViewVM(
				.constant(patientDetails.salutation),
				Texts.salutation),
			TextAndTextViewVM(
				.constant(patientDetails.firstName),
				Texts.firstName),
			TextAndTextViewVM(
				.constant(patientDetails.lastName),
				Texts.lastName)
		],
		[
			TextAndTextViewVM(
				.constant(patientDetails.dob),
				Texts.dob),
			TextAndTextViewVM(
				.constant(patientDetails.phone),
				Texts.phone),
			TextAndTextViewVM(
				.constant(patientDetails.cellPhone),
				Texts.cellPhone)
		],
		[
			TextAndTextViewVM(
				.constant(patientDetails.email),
				Texts.email),
			TextAndTextViewVM(
				.constant(patientDetails.addressLine1),
				Texts.addressLine1),
			TextAndTextViewVM(
				.constant(patientDetails.addressLine2),
				Texts.addressLine2)
		],
		[
			TextAndTextViewVM(
				.constant(patientDetails.postCode),
				Texts.postCode),
			TextAndTextViewVM(
				.constant(patientDetails.city),
				Texts.city),
			TextAndTextViewVM(
				.constant(patientDetails.county),
				Texts.county)
		],
		[
			TextAndTextViewVM(
				.constant(patientDetails.country),
				Texts.country),
			TextAndTextViewVM(
				.constant(patientDetails.howDidYouHear),
				Texts.howDidUHear)
		]
	]
}
