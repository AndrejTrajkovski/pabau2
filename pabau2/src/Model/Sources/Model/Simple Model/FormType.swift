//
// FormType.swift

import Foundation

public enum FormType: String, Codable, Equatable {
	case questionnaire = "questionnaire"
	//    case questionnaire = "questionnaire"
	case treatment = "treatment"
	case consent = "consent"
	case prescription = "prescription"
//	case photos = "photos"
}
