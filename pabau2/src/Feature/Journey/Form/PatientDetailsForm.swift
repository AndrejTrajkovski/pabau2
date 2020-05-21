import SwiftUI
import Util
import ComposableArchitecture

struct PatientDetailsForm: View {
	
	var patientDetails: PatientDetails
	
	let vms: [[TextAndTextViewVM]] = [
		[
			TextAndTextViewVM(.constant("Mr"), Texts.salutation),
			TextAndTextViewVM(.constant("Jonathan"), Texts.firstName),
			TextAndTextViewVM(.constant("Davis"), Texts.lastName)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.dob),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.phone),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.cellPhone)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.email),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.addressLine1),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.addressLine2)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.postCode),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.city),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.county)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.country),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.howDidUHear)
		]
	]

	var body: some View {
		print("Patient details body")
		return VStack {
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


public enum PatientDetailsAction {
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
}

public let patientDetailsReducer: Reducer<PatientDetails, PatientDetailsAction, Any> = .combine(
	textFieldReducer.pullback(
		state: \.salutation,
		action: /TextFieldAction.salutation,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.firstName,
		action: /TextFieldAction.firstName,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.lastName,
		action: /TextFieldAction.lastName,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.dob,
		action: /TextFieldAction.dob,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.phone,
		action: /TextFieldAction.phone,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.cellPhone,
		action: /TextFieldAction.cellPhone,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.email,
		action: /TextFieldAction.email,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.addressLine1,
		action: /TextFieldAction.addressLine1,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.addressLine2,
		action: /TextFieldAction.addressLine2,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.postCode,
		action: /TextFieldAction.postCode,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.city,
		action: /TextFieldAction.city,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.county,
		action: /TextFieldAction.county,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.country,
		action: /TextFieldAction.country,
		environment: { $0 }
	),
	textFieldReducer.pullback(
		state: \.howDidYouHear,
		action: /TextFieldAction.howDidYouHear,
		environment: { $0 }
	)
)
