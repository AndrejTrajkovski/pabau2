import Foundation
import Tagged

public struct HTMLFormTemplate: Codable, Identifiable, Equatable, CustomDebugStringConvertible {
	
	public var debugDescription: String {
		return name
	}
	
	public typealias ID = Tagged<HTMLFormTemplate, Int>
	
	public let id: HTMLFormTemplate.ID
	
	public let name: String
	
	public let formType: FormType
	
	public let ePaper: Bool?
	
	public var formStructure: FormStructure
	public init(id: Int,
				name: String,
				formType: FormType,
				ePaper: Bool? = nil,
				formStructure: FormStructure) {
		self.id = HTMLFormTemplate.ID(rawValue: id)
		self.name = name
		self.formType = formType
		self.ePaper = ePaper
		self.formStructure = formStructure
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case name
		case formType = "form_type"
		case ePaper
		case formStructure = "form_structure"
	}
}

extension HTMLFormTemplate {
	
	public static let mockConsents  = [
		HTMLFormTemplate(id: 1,
						 name: "Consent - Transplant",
						 formType: .consent,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "")),
										 _required: true,
										 title: "Insert some text"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 _required: true,
										 title: "Please enter some text below"
								),
								CSSField(id: 1,
										 cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 _required: true,
										 title: "Choose please"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 1"),
															 RadioChoice("radio choice 2")])
										 ), title: "Radio title"
								),
								CSSField(id: 51,
										 cssClass: .select(SelectState(4,
																	   [SelectChoice(1, "select choice with a multiline text with a multiline text with a multiline text with a multiline text with a multiline text with a multiline text with a multiline text"),
																		SelectChoice(2, "select choice 2"),
																		SelectChoice(3, "select choice 3"),
																		SelectChoice(4, "select choice 4")
																	   ])
										 ), title: "Select title"
								)
							])),
		
		HTMLFormTemplate(id: 2, name: "Consent - Botox", formType: .consent,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 1, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signatureeee"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "yada yada yada"
								),
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Sign this please"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 51,
										 cssClass: .select(SelectState(4,
																	   [SelectChoice(1, "select choice 1"),
																		SelectChoice(2, "select choice 2"),
																		SelectChoice(3, "select choice 3"),
																		SelectChoice(4, "select choice 4")
																	   ],
																	   1)
										 ), title: "Select title"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 3"),
															 RadioChoice("radio choice 4")])
										 ), title: "Radio title"
								),
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "input some text")),
										 title: "Insert some text bla bla"
								)
							])),
		HTMLFormTemplate(id: 3, name: "Test Consent", formType: .consent,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 51,
										 cssClass: .select(SelectState(4,
																	   [SelectChoice(1, "select choice 1"),
																		SelectChoice(2, "select choice 2"),
																		SelectChoice(3, "select choice 3"),
																		SelectChoice(4, "select choice 4")
																	   ],
																	   1)
										 ), title: "Select title"
								),
								CSSField(id: 1, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Do you have a history of ?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 5"),
															 RadioChoice("radio choice 6")])
										 ), title: "Radio title"
								),
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								)
							])),
		HTMLFormTemplate(id: 4, name: "Vaccines", formType: .consent,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 1, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 51,
										 cssClass: .select(SelectState(4,
																	   [SelectChoice(1, "select choice 1"),
																		SelectChoice(2, "select choice 2"),
																		SelectChoice(3, "select choice 3"),
																		SelectChoice(4, "select choice 4")
																	   ],
																	   1)
										 ), title: "Select title"
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 7"),
															 RadioChoice("radio choice 8")])
										 ), title: "Radio title"
								)
							])),
		HTMLFormTemplate(id: 123, name: "Signature Consent", formType: .consent,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 1, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 11"),
															 RadioChoice("radio choice 12")])
										 ), title: "Radio title"
								)
							])),
		HTMLFormTemplate(id: 1234231231231233, name: "Massage Consent", formType: .consent,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 1, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 1"),
															 RadioChoice("radio choice 2")])
										 ), title: "Radio title"
								)
							])),
	]
	
	public static let mockTreatmentN  = [
		HTMLFormTemplate(id: 1, name: "Treatment - Transplant", formType: .treatment,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 81,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 61,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 91,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 71,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 51,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 11, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 21, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 31, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 41,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 1"),
															 RadioChoice("radio choice 2")])
										 ), title: "Radio title"
								)
							])),
		HTMLFormTemplate(id: 2, name: "Treatment - Botox", formType: .treatment,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 12, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 62,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signatureeee"
								),
								CSSField(id: 92,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "yada yada yada"
								),
								CSSField(id: 72,
										 cssClass: .signature(SignatureState()),
										 title: "Sign this please"
								),
								CSSField(id: 52,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 22, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 32, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 42,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 3"),
															 RadioChoice("radio choice 4")])
										 ), title: "Radio title"
								),
								CSSField(id: 82,
										 cssClass: .input_text(InputText(text: "input some text")),
										 title: "Insert some text bla bla"
								)
							])),
		HTMLFormTemplate(id: 3, name: "Test Treatment", formType: .treatment,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 83,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 63,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 93,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 73,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 53,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 13, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 23, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 33, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 43,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 5"),
															 RadioChoice("radio choice 6")])
										 ), title: "Radio title"
								)
							])),
		HTMLFormTemplate(id: 4, name: "Treatment Vaccines", formType: .treatment,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 84,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 64,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 94,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 74,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 54,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 14, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 24, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 34, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 44,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 7"),
															 RadioChoice("radio choice 8")])
										 ), title: "Radio title"
								)
							])),
		HTMLFormTemplate(id: 123, name: "Signature Treatment", formType: .treatment,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 85,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 65,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 95,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 75,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 55,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 15, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 25, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 35, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 45,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 11"),
															 RadioChoice("radio choice 12")])
										 ), title: "Radio title"
								)
							])),
		HTMLFormTemplate(id: 123423, name: "Treatmentzzz",
						 formType: .treatment,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 86,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 _required: true,
										 title: "Insert some text"
								),
								CSSField(id: 66,
										 cssClass: .signature(SignatureState()),
										 _required: true,
										 title: "Patient signature"
								),
								CSSField(id: 96,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 _required: true,
										 title: "Insert some text 2"
								),
								CSSField(id: 76,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 56,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 16, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 26, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 36, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 46,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 1"),
															 RadioChoice("radio choice 2")])
										 ), title: "Radio title"
								)
							])),
	]
	
	
	public static func getMedHistory() -> HTMLFormTemplate {
		HTMLFormTemplate(id: 1, name: "Medical History Form", formType: .history,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 51,
										 cssClass: .select(SelectState(4,
																	   [SelectChoice(1, "select choice with a multiline text with a multiline text with a multiline text with a multiline text with a multiline text with a multiline text with a multiline text"),
																		SelectChoice(2, "select choice 2"),
																		SelectChoice(3, "select choice 3"),
																		SelectChoice(4, "select choice 4")
																	   ],
																	   1)
										 ), title: "Select title"
								),
								CSSField(id: 1151,
										 cssClass: .select(SelectState(4,
																	   [SelectChoice(1, "select choice 1"),
																		SelectChoice(2, "select choice 2"),
																		SelectChoice(3, "select choice 3"),
																		SelectChoice(4, "select choice 4")
																	   ],
																	   nil)
										 ),
										 _required: true,
										 title: "Select field that's required"
								),
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "This is med history input 1")),
										 title: "Insert some text"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 _required: true,
										 title: "Patient signature"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 1, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 1"),
															 RadioChoice("radio choice 2")])
										 ), title: "Radio title"
								)
							]))
	}
	public static func getPrescription() -> HTMLFormTemplate {
		HTMLFormTemplate(id: 1, name: "Prescription Form", formType: .prescription,
						 ePaper: false,
						 formStructure:
							FormStructure(formStructure: [
								CSSField(id: 8,
										 cssClass: .input_text(InputText(text: "input text 1")),
										 title: "Insert some text"
								),
								CSSField(id: 6,
										 cssClass: .signature(SignatureState()),
										 title: "Patient signature"
								),
								CSSField(id: 9,
										 cssClass: .input_text(InputText(text: "input text 2")),
										 title: "Insert some text 2"
								),
								CSSField(id: 7,
										 cssClass: .signature(SignatureState()),
										 title: "Practitioner signature"
								),
								CSSField(id: 5,
										 cssClass: .textarea(TextArea(text: "some text")),
										 title: "Please enter some text below"
								),
								CSSField(id: 1, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "Are you currently receiving any medical treatment at present?"),
													CheckBoxChoice( "Have you received Roaccutane/Accutane treatment in the past 12 months?"),
													CheckBoxChoice( "Have you ever suffered from an allergic reaction to lignocaine / lidocaine?"),
													CheckBoxChoice( "Do you have a history of anaphylactic shock (severe allergic reactions) Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)? tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions) tic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)Do you have a history of anaphylactic shock (severe allergic reactions)"),
													CheckBoxChoice( "Have you undergone any laser skin resurfacing, skin peel or dermabrasion?"),
													CheckBoxChoice( "Do you have or have you ever had any form of skin cancer?"),
													CheckBoxChoice( "Have you been treated with any dermal fillers on either your face and/or body?")
												]
											),
										 title: "Choose please"
								),
								CSSField(id: 2, cssClass:
											.checkboxes(
												[
													CheckBoxChoice( "choice 3"),
													CheckBoxChoice( "choice 4"),
													CheckBoxChoice( "choice 5")
												]
											),
										 title: "Choose smth else"
								),
								CSSField(id: 3, cssClass:
											.staticText(StaticText( "Hey what's going on?")),
										 title: "This is some static text "
								),
								CSSField(id: 4,
										 cssClass: .radio(RadioState(
															[RadioChoice("radio choice 1"),
															 RadioChoice("radio choice 2")])
										 ), title: "Radio title"
								)
							]))
	}
	
}
