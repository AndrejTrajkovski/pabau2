import ComposableArchitecture
import NonEmpty
import SwiftDate

public struct JourneyMockAPI: MockAPI, JourneyAPI {
	public init () {}
	public func getJourneys(date: Date) -> Effect<Result<[Journey], RequestError>> {
		mockSuccess(Self.mockJourneys, delay: 0.2)
	}

	public func getEmployees() -> Effect<Result<[Employee], RequestError>> {
		mockSuccess(Self.mockEmployees, delay: 0.0)
	}

	public func getTemplates(_ type: FormType) -> Effect<Result<[FormTemplate], RequestError>> {
		switch type {
		case .consent:
		  return mockSuccess(Self.mockConsents, delay: 0.1)
		case .treatment:
			return mockSuccess(Self.mockTreatmentN, delay: 0.1)
		default:
		fatalError("TODO")
		}
	}
}

extension JourneyMockAPI {
	static let mockEmployees = [
		Employee.init(id: 1,
									name: "Dr. Jekil",
									avatarUrl: "asd",
									pin: 1234),
		Employee.init(id: 2,
									name: "Dr. Off Boley",
									avatarUrl: "",
									pin: 1234),
		Employee.init(id: 3,
									name: "Michael Jordan",
									avatarUrl: "",
									pin: 1234),
		Employee.init(id: 4,
									name: "Kobe Bryant",
									avatarUrl: "",
									pin: 1234),
		Employee.init(id: 5,
									name: "LeBron James",
									avatarUrl: "",
									pin: 1234),
		Employee.init(id: 6,
									name: "Britney Spears",
									avatarUrl: "",
									pin: 1234),
		Employee.init(id: 7,
									name: "Dr. Who",
									avatarUrl: "",
									pin: 1234)
	]

	static let mockJourneys = [
		Journey.init(id: 1,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#9400D3"))),
								 patient: BaseClient.init(id: 0, firstName: "Andrej", lastName: "Trajkovski", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
		Journey.init(id: 2,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
								 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 1, name: "Dr. Jekil"), forms: [], photos: [], postCare: [], paid: "Paid"),
		Journey.init(id: 3,
								 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() - 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
								 patient: BaseClient.init(id: 2, firstName: "Madonna", lastName: "", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 2, name: "Dr. Off Boley"), forms: [], photos: [], postCare: [], paid: "Broke"),
			Journey.init(id: 4,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Checked In"), service: BaseService.init(id: 1, name: "Corona Virus", color: "#FFFF00"))),
									 patient: BaseClient.init(id: 0, firstName: "Carl", lastName: "Cox", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 4,
									 name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Not Paid"),
			Journey.init(id: 5,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date(), to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#ec75ff"))),
									 patient: BaseClient.init(id: 1, firstName: "Elon", lastName: "Musk", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 4,
																																																																																									name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Paid"),
			Journey.init(id: 6,
									 appointments: NonEmpty.init(Appointment.init(id: 1, from: Date() + 1.days, to: Date(), employeeId: 1, locationId: 1, status: AppointmentStatus(id: 1, name: "Not Checked In"), service: BaseService.init(id: 1, name: "Botox", color: "#88fa69"))),
									 patient: BaseClient.init(id: 2, firstName: "Joe", lastName: "Rogan", dOB: "28.02.1991", email: "andrej.", avatar: "emily", phone: ""), employee: Employee.init(id: 4,
									 name: "Kobe Bryant"), forms: [], photos: [], postCare: [], paid: "Owes 1.000")
	]

	public static let mockConsents  = [
		FormTemplate(id: 1, name: "Consent - Transplant", formType: .consent,
								 ePaper: false,
								 formStructure:
			FormStructure(formStructure: [
				CSSField(id: 8,
								 cssClass: .input_text(InputText(text: "input text 1")),
								 title: "Insert some text"
				),
				CSSField(id: 6,
								 cssClass: .signature(Signature()),
								 title: "Patient signature"
				),
				CSSField(id: 9,
								 cssClass: .input_text(InputText(text: "input text 2")),
								 title: "Insert some text 2"
				),
				CSSField(id: 7,
								 cssClass: .signature(Signature()),
								 title: "Practitioner signature"
				),
				CSSField(id: 5,
								 cssClass: .textarea(TextArea(text: "some text")),
								 title: "Please enter some text below"
				),
				CSSField(id: 1, cssClass:
					.checkboxes(
						[
							CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
							CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
							CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
							CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
							 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
							 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
							 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
						]
					),
					title: "Choose please"
				),
				CSSField(id: 2, cssClass:
					.checkboxes(
						[
							CheckBoxChoice(3, "choice 3", false),
							CheckBoxChoice(4, "choice 4", false),
							CheckBoxChoice(5, "choice 5", true)
						]
					),
					title: "Choose smth else"
				),
				CSSField(id: 3, cssClass:
					.staticText(StaticText(1, "Hey what's going on?")),
								 title: "This is some static text "
				),
				CSSField(id: 4,
								 cssClass: .radio(Radio(4,
																				[RadioChoice(1, "radio choice 1"),
																				 RadioChoice(2, "radio choice 2")],
																				1)
					), title: "Radio title"
				)
			])),
		FormTemplate(id: 2, name: "Consent - Botox", formType: .consent,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signatureeee"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "yada yada yada"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Sign this please"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 3"),
																			 RadioChoice(2, "radio choice 4")],
																			1)
				), title: "Radio title"
			),
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input some text")),
							 title: "Insert some text bla bla"
			)
		])),
		FormTemplate(id: 3, name: "Test Consent", formType: .consent,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 5"),
																			 RadioChoice(2, "radio choice 6")],
																			1)
				), title: "Radio title"
			)
		])),
		FormTemplate(id: 4, name: "Vaccines", formType: .consent,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 7"),
																			 RadioChoice(2, "radio choice 8")],
																			1)
				), title: "Radio title"
			)
		])),
		FormTemplate(id: 123, name: "Signature Consent", formType: .consent,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 11"),
																			 RadioChoice(2, "radio choice 12")],
																			1)
				), title: "Radio title"
			)
		])),
		FormTemplate(id: 123423, name: "Thai Massage Consent", formType: .consent,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 1"),
																			 RadioChoice(2, "radio choice 2")],
																			1)
				), title: "Radio title"
			)
		])),
	]
	
	public static let mockTreatmentN  = [
		FormTemplate(id: 1, name: "Treatment - Transplant", formType: .treatment,
								 ePaper: false,
								 formStructure:
			FormStructure(formStructure: [
				CSSField(id: 8,
								 cssClass: .input_text(InputText(text: "input text 1")),
								 title: "Insert some text"
				),
				CSSField(id: 6,
								 cssClass: .signature(Signature()),
								 title: "Patient signature"
				),
				CSSField(id: 9,
								 cssClass: .input_text(InputText(text: "input text 2")),
								 title: "Insert some text 2"
				),
				CSSField(id: 7,
								 cssClass: .signature(Signature()),
								 title: "Practitioner signature"
				),
				CSSField(id: 5,
								 cssClass: .textarea(TextArea(text: "some text")),
								 title: "Please enter some text below"
				),
				CSSField(id: 1, cssClass:
					.checkboxes(
						[
							CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
							CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
							CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
							CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
							 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
							 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
							 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
						]
					),
					title: "Choose please"
				),
				CSSField(id: 2, cssClass:
					.checkboxes(
						[
							CheckBoxChoice(3, "choice 3", false),
							CheckBoxChoice(4, "choice 4", false),
							CheckBoxChoice(5, "choice 5", true)
						]
					),
					title: "Choose smth else"
				),
				CSSField(id: 3, cssClass:
					.staticText(StaticText(1, "Hey what's going on?")),
								 title: "This is some static text "
				),
				CSSField(id: 4,
								 cssClass: .radio(Radio(4,
																				[RadioChoice(1, "radio choice 1"),
																				 RadioChoice(2, "radio choice 2")],
																				1)
					), title: "Radio title"
				)
			])),
		FormTemplate(id: 2, name: "Treatment - Botox", formType: .treatment,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signatureeee"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "yada yada yada"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Sign this please"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 3"),
																			 RadioChoice(2, "radio choice 4")],
																			1)
				), title: "Radio title"
			),
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input some text")),
							 title: "Insert some text bla bla"
			)
		])),
		FormTemplate(id: 3, name: "Test Treatment", formType: .treatment,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 5"),
																			 RadioChoice(2, "radio choice 6")],
																			1)
				), title: "Radio title"
			)
		])),
		FormTemplate(id: 4, name: "Treatment Vaccines", formType: .treatment,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 7"),
																			 RadioChoice(2, "radio choice 8")],
																			1)
				), title: "Radio title"
			)
		])),
		FormTemplate(id: 123, name: "Signature Treatment", formType: .treatment,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 11"),
																			 RadioChoice(2, "radio choice 12")],
																			1)
				), title: "Radio title"
			)
		])),
		FormTemplate(id: 123423, name: "Treatmentzzz", formType: .treatment,
							 ePaper: false,
							 formStructure:
		FormStructure(formStructure: [
			CSSField(id: 8,
							 cssClass: .input_text(InputText(text: "input text 1")),
							 title: "Insert some text"
			),
			CSSField(id: 6,
							 cssClass: .signature(Signature()),
							 title: "Patient signature"
			),
			CSSField(id: 9,
							 cssClass: .input_text(InputText(text: "input text 2")),
							 title: "Insert some text 2"
			),
			CSSField(id: 7,
							 cssClass: .signature(Signature()),
							 title: "Practitioner signature"
			),
			CSSField(id: 5,
							 cssClass: .textarea(TextArea(text: "some text")),
							 title: "Please enter some text below"
			),
			CSSField(id: 1, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
						CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
						CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
						CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
						 CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
						 CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
						 CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
					]
				),
				title: "Choose please"
			),
			CSSField(id: 2, cssClass:
				.checkboxes(
					[
						CheckBoxChoice(3, "choice 3", false),
						CheckBoxChoice(4, "choice 4", false),
						CheckBoxChoice(5, "choice 5", true)
					]
				),
				title: "Choose smth else"
			),
			CSSField(id: 3, cssClass:
				.staticText(StaticText(1, "Hey what's going on?")),
							 title: "This is some static text "
			),
			CSSField(id: 4,
							 cssClass: .radio(Radio(4,
																			[RadioChoice(1, "radio choice 1"),
																			 RadioChoice(2, "radio choice 2")],
																			1)
				), title: "Radio title"
			)
		])),
	]

	
	public static func getMedHistory() -> FormTemplate {
		FormTemplate(id: 1, name: "Medical History Form", formType: .consent,
								 ePaper: false,
								 formStructure:
			FormStructure(formStructure: [
				CSSField(id: 8,
								 cssClass: .input_text(InputText(text: "input text 1")),
								 title: "Insert some text"
				),
				CSSField(id: 6,
								 cssClass: .signature(Signature()),
								 title: "Patient signature"
				),
				CSSField(id: 9,
								 cssClass: .input_text(InputText(text: "input text 2")),
								 title: "Insert some text 2"
				),
				CSSField(id: 7,
								 cssClass: .signature(Signature()),
								 title: "Practitioner signature"
				),
				CSSField(id: 5,
								 cssClass: .textarea(TextArea(text: "some text")),
								 title: "Please enter some text below"
				),
				CSSField(id: 1, cssClass:
					.checkboxes(
						[
							CheckBoxChoice(1, "Are you currently receiving any medical treatment at present?", false),
							CheckBoxChoice(2, "Have you received Roaccutane/Accutane treatment in the past 12 months?", false),
							CheckBoxChoice(3, "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?", false),
							CheckBoxChoice(4, "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)", false),
							CheckBoxChoice(5, "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?", false),
							CheckBoxChoice(6, "Do you have or have you ever had any form of skin cancer?", false),
							CheckBoxChoice(7, "Have you been treated with any dermal fillers on either your face and/or body?", false)
						]
					),
								 title: "Choose please"
				),
				CSSField(id: 2, cssClass:
					.checkboxes(
						[
							CheckBoxChoice(3, "choice 3", false),
							CheckBoxChoice(4, "choice 4", false),
							CheckBoxChoice(5, "choice 5", true)
						]
					),
								 title: "Choose smth else"
				),
				CSSField(id: 3, cssClass:
					.staticText(StaticText(1, "Hey what's going on?")),
								 title: "This is some static text "
				),
				CSSField(id: 4,
								 cssClass: .radio(Radio(4,
																				[RadioChoice(1, "radio choice 1"),
																				 RadioChoice(2, "radio choice 2")],
																				1)
					), title: "Radio title"
				)
			]))
	}
}
