import SwiftUI
import Util
import ComposableArchitecture

struct PatientDetailsForm: View {
	let store: Store<PatientDetails, PatientDetailsAction>
	@ObservedObject var viewStore: ViewStore<PatientDetails, PatientDetailsAction>
	let vms: [[TextAndTextViewVM]]
	
	init(store: Store<PatientDetails, PatientDetailsAction>) {
		self.store = store
		let viewStore = ViewStore(store)
		self.vms = viewModels(viewStore)
		self.viewStore = viewStore
	}

	var body: some View {
		print("Patient details body")
		return
			ScrollView {
				VStack {
					PatientDetailsTextFields(vms: self.vms)
					FourSwitchesSection(
						swithc1: viewStore.binding(
							get: { $0.emailComm },
							send: { .emailComm(.setTo($0)) }),
						switch2: viewStore.binding(
							get: { $0.smsComm },
							send: { .smsComm(.setTo($0)) }),
						switch3: viewStore.binding(
							get: { $0.phoneComm },
							send: { .phoneComm(.setTo($0)) }),
						switch4: viewStore.binding(
							get: { $0.postComm },
							send: { .postComm(.setTo($0)) }),
						switchNames: [
							Texts.emailConfirmations,
							Texts.smsReminders,
							Texts.phone,
							Texts.post
						],
						title: Texts.communications
					)
				}
		}
	}
}

struct PatientDetailsTextFields: View {
	let vms: [[TextAndTextViewVM]]
	var body: some View {
		VStack {
			ThreeTextColumns(self.vms[0], isFirstFixSized: true)
			ThreeTextColumns(self.vms[1])
			ThreeTextColumns(self.vms[2])
			ThreeTextColumns(self.vms[3])
			ThreeTextColumns(self.vms[4])
		}
	}
}

struct TextAndTextViewVM {
	let value: Binding<String>
	let title: String
	init(_ value: Binding<String>, _ title: String) {
		self.value = value
		self.title = title
	}
}

struct ThreeTextColumns: View {
	let vms: [TextAndTextViewVM]
	let isFirstFixSized: Bool

	init(_ vms: [TextAndTextViewVM], isFirstFixSized: Bool = false) {
		self.vms = vms
		self.isFirstFixSized = isFirstFixSized
	}

	var body: some View {
		HStack {
			TextAndTextField(self.vms[0].title,
											 self.vms[0].value)
				.fixedSize(horizontal: isFirstFixSized, vertical: false)
			Spacer()
			TextAndTextField(self.vms[1].title,
											 self.vms[1].value)
			Spacer()
			if self.vms.count == 3 {
				TextAndTextField(self.vms[2].title,
												 self.vms[2].value)
			} else {
				Spacer()
					.fixedSize(horizontal: false, vertical: true)
			}
		}
	}
}

public enum PatientDetailsAction: Equatable {
	case salutation(TextFieldAction)
	case firstName(TextFieldAction)
	case lastName(TextFieldAction)
	case dob(TextFieldAction)
	case phone(TextFieldAction)
	case cellPhone(TextFieldAction)
	case email(TextFieldAction)
	case addressLine1(TextFieldAction)
	case addressLine2(TextFieldAction)
	case postCode(TextFieldAction)
	case city(TextFieldAction)
	case county(TextFieldAction)
	case country(TextFieldAction)
	case howDidYouHear(TextFieldAction)
	case emailComm(ToggleAction)
	case smsComm(ToggleAction)
	case phoneComm(ToggleAction)
	case postComm(ToggleAction)
}

public let patientDetailsReducer: Reducer<PatientDetails, PatientDetailsAction, Any> = (
	.combine(
		textFieldReducer.pullback(
			state: \PatientDetails.salutation,
			action: /PatientDetailsAction.salutation,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.firstName,
			action: /PatientDetailsAction.firstName,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.lastName,
			action: /PatientDetailsAction.lastName,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.dob,
			action: /PatientDetailsAction.dob,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.phone,
			action: /PatientDetailsAction.phone,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.cellPhone,
			action: /PatientDetailsAction.cellPhone,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.email,
			action: /PatientDetailsAction.email,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.addressLine1,
			action: /PatientDetailsAction.addressLine1,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.addressLine2,
			action: /PatientDetailsAction.addressLine2,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.postCode,
			action: /PatientDetailsAction.postCode,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.city,
			action: /PatientDetailsAction.city,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.county,
			action: /PatientDetailsAction.county,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.country,
			action: /PatientDetailsAction.country,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \PatientDetails.howDidYouHear,
			action: /PatientDetailsAction.howDidYouHear,
			environment: { $0 }
		),
		switchCellReducer.pullback(
			state: \PatientDetails.emailComm,
			action: /PatientDetailsAction.emailComm,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \PatientDetails.smsComm,
			action: /PatientDetailsAction.smsComm,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \PatientDetails.phoneComm,
			action: /PatientDetailsAction.phoneComm,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \PatientDetails.postComm,
			action: /PatientDetailsAction.postComm,
			environment: { $0 })
	)
)

func viewModels(_ viewStore: ViewStore<PatientDetails, PatientDetailsAction>) -> [[TextAndTextViewVM]] {
	[
		[
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.salutation },
					send: { .salutation(.textFieldChanged($0)) }),
				Texts.salutation),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.firstName },
					send: { .firstName(.textFieldChanged($0)) }),
				Texts.firstName),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.lastName },
					send: { .lastName(.textFieldChanged($0)) }),
				Texts.lastName)
		],
		[
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.dob },
					send: { .dob(.textFieldChanged($0)) }),
				Texts.dob),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.phone },
					send: { .phone(.textFieldChanged($0)) }),
				Texts.phone),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.cellPhone },
					send: { .cellPhone(.textFieldChanged($0)) }),
				Texts.cellPhone)
		],
		[
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.email },
					send: { .email(.textFieldChanged($0)) }),
				Texts.email),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.addressLine1 },
					send: { .addressLine1(.textFieldChanged($0)) }),
				Texts.addressLine1),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.addressLine2 },
					send: { .addressLine2(.textFieldChanged($0)) }),
				Texts.addressLine2)
		],
		[
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.postCode },
					send: { .postCode(.textFieldChanged($0)) }),
				Texts.postCode),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.city },
					send: { .city(.textFieldChanged($0)) }),
				Texts.city),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.county },
					send: { .county(.textFieldChanged($0)) }),
				Texts.county)
		],
		[
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.country },
					send: { .country(.textFieldChanged($0)) }),
				Texts.country),
			TextAndTextViewVM(
				viewStore.binding(
					get: { $0.howDidYouHear },
					send: { .howDidYouHear(.textFieldChanged($0)) }),
				Texts.howDidUHear)
		]
	]
}
