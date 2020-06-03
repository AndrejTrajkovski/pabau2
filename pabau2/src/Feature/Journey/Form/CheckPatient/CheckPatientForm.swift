import SwiftUI
import ComposableArchitecture
import Util
import Model

struct CheckPatientForm: View {
	let didTouchDone: () -> Void
	let patDetails: PatientDetails
	let patientForms: [FormTemplate]

	var body: some View {
		ScrollView {
			VStack {
				PatientDetailsTextFields(vms: viewModels(patDetails))
				FourSwitchesSection(
					swithc1: .constant(patDetails.emailComm),
					switch2: .constant(patDetails.smsComm),
					switch3: .constant(patDetails.phoneComm),
					switch4: .constant(patDetails.postComm),
					switchNames: [
						Texts.emailConfirmations,
						Texts.smsReminders,
						Texts.phone,
						Texts.post
					],
					title: Texts.communications
				)
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
