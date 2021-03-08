import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents
import SwiftDate

public struct PatientDetailsForm: View {
	let store: Store<ClientBuilder, PatientDetailsAction>
//	@ObservedObject var viewStore: ViewStore<ClientBuilder, PatientDetailsAction>

	public init(store: Store<ClientBuilder, PatientDetailsAction>) {
		self.store = store
//		let viewStore = ViewStore(store)
//		self.viewStore = viewStore
	}
	
	public var body: some View {
		ScrollView {
			VStack {
				HStack {
					SalutationPicker(store: store.scope(state: { $0.salutation },
														action: { .salutation($0) }))
					TextAndTextFieldStore(store: store.scope(state: { $0.firstName },
															 action: { .firstName($0) }),
										  title: Texts.firstName)
					TextAndTextFieldStore(store: store.scope(state: { $0.lastName },
															 action: { .lastName($0) }),
										  title: Texts.lastName)
				}
				
				HStack {
					PatientDetailsField(Texts.dob) {
						DatePickerTCA(mode: .date,
									  store: store.scope( state: { $0.dOB }, action: { .dob($0) }),
									  borderStyle: .none
						)
					}
					TextAndTextFieldStore(store: store.scope(state: { $0.phone },
															 action: { .phone($0) }),
										  title: Texts.phone)
						.keyboardType(.phonePad)
					TextAndTextFieldStore(store: store.scope(state: { $0.mobile },
															 action: { .cellPhone($0) }),
										  title: Texts.cellPhone)
						.keyboardType(.phonePad)
				}
				
				HStack {
					TextAndTextFieldStore(store: store.scope(state: { $0.email },
															 action: { .email($0) }),
										  title: Texts.email)
						.keyboardType(.emailAddress)
					TextAndTextFieldStore(store: store.scope(state: { $0.mailingStreet },
															 action: { .street($0) }),
										  title: Texts.street)
					TextAndTextFieldStore(store: store.scope(state: { $0.otherStreet },
															 action: { .otherStreet($0) }),
										  title: Texts.otherStreet)
				}
				
				HStack {
					TextAndTextFieldStore(store: store.scope(state: { $0.mailingPostal },
															 action: { .postCode($0) }),
										  title: Texts.postCode)
					TextAndTextFieldStore(store: store.scope(state: { $0.mailingCity },
															 action: { .city($0) }),
										  title: Texts.city)
					TextAndTextFieldStore(store: store.scope(state: { $0.mailingCounty },
															 action: { .county($0) }),
										  title: Texts.county)
				}

				HStack {
					TextAndTextFieldStore(store: store.scope(state: { $0.mailingCountry },
															 action: { .country($0) }),
										  title: Texts.country)
					TextAndTextFieldStore(store: store.scope(state: { $0.howDidYouHear },
															 action: { .howDidYouHear($0) }),
										  title: Texts.howDidUHear)
					Spacer()
						.fixedSize(horizontal: false, vertical: true)
				}
				
				Group {
					SwitchCell(text: Texts.emailConfirmations,
							   store: store.scope(
								state: { $0.optInEmail },
								action: { .emailComm($0) })
					)
					SwitchCell(text: Texts.smsReminders,
							   store: store.scope(
								state: { $0.optInSms },
								action: { .smsComm($0) })
					)
					SwitchCell(text: Texts.phone,
							   store: store.scope(
								state: { $0.optInPhone },
								action: { .phoneComm($0) })
					)
					SwitchCell(text: Texts.post,
							   store: store.scope(
								state: { $0.optInPost },
								action: { .postComm($0) })
					)
				}.switchesSection(title: Texts.communications)
			}
		}
	}
}

struct PatientDetailsTextFields: View {
	let store: Store<ClientBuilder, PatientDetailsAction>
	var body: some View {
		VStack {
//			ThreeTextColumns(self.vms[0], isFirstFixSized: false)
//			ThreeTextColumns(self.vms[1])
//			ThreeTextColumns(self.vms[2])
//			ThreeTextColumns(self.vms[3])
//			ThreeTextColumns(self.vms[4])
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

struct TextAndTextFieldStore: View {
	let store: Store<String, TextChangeAction>
	let title: String
	var body: some View {
		WithViewStore(store) { viewStore in
			TextAndTextField(title,
							 viewStore.binding(get: { $0 },
											   send: TextChangeAction.textChange))
		}
	}
}

public enum PatientDetailsAction: Equatable {
	case salutation(SalutationPickerAction)
	case firstName(TextChangeAction)
	case lastName(TextChangeAction)
	case dob(DatePickerTCAAction)
	case phone(TextChangeAction)
	case cellPhone(TextChangeAction)
	case email(TextChangeAction)
	case street(TextChangeAction)
	case otherStreet(TextChangeAction)
	case postCode(TextChangeAction)
	case city(TextChangeAction)
	case county(TextChangeAction)
	case country(TextChangeAction)
	case howDidYouHear(TextChangeAction)
	case emailComm(ToggleAction)
	case smsComm(ToggleAction)
	case phoneComm(ToggleAction)
	case postComm(ToggleAction)
	case complete
}

public let patientDetailsReducer: Reducer<ClientBuilder, PatientDetailsAction, Any> = (
	.combine(
		.init { state, action, _ in
			switch action {
			case .salutation(.pick(let salutation)):
				state.salutation = salutation
			default:
				break
			}
			return .none
		},
		textFieldReducer.pullback(
			state: \ClientBuilder.firstName,
			action: /PatientDetailsAction.firstName,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.lastName,
			action: /PatientDetailsAction.lastName,
			environment: { $0 }
		),
		datePickerReducer.pullback(
            state: \ClientBuilder.dOB,
			action: /PatientDetailsAction.dob,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.phone,
			action: /PatientDetailsAction.phone,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.mobile,
			action: /PatientDetailsAction.cellPhone,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.email,
			action: /PatientDetailsAction.email,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.mailingStreet,
			action: /PatientDetailsAction.street,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.otherStreet,
			action: /PatientDetailsAction.otherStreet,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.mailingPostal,
			action: /PatientDetailsAction.postCode,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.mailingCity,
			action: /PatientDetailsAction.city,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.mailingCounty,
			action: /PatientDetailsAction.county,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.mailingCountry,
			action: /PatientDetailsAction.country,
			environment: { $0 }
		),
		textFieldReducer.pullback(
			state: \ClientBuilder.howDidYouHear,
			action: /PatientDetailsAction.howDidYouHear,
			environment: { $0 }
		),
		switchCellReducer.pullback(
			state: \ClientBuilder.optInEmail,
			action: /PatientDetailsAction.emailComm,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \ClientBuilder.optInSms,
			action: /PatientDetailsAction.smsComm,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \ClientBuilder.optInPhone,
			action: /PatientDetailsAction.phoneComm,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \ClientBuilder.optInPost,
			action: /PatientDetailsAction.postComm,
			environment: { $0 })
	)
)
