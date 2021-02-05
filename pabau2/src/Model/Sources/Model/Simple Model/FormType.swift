//
// FormType.swift

import Foundation

public enum FormType: String, Codable, Equatable {
	case history = "history"
//  case questionnaire = "questionnaire"
	case treatment = "treatment"
	case consent = "consent"
	case prescription = "prescription"
    case unknown
//	case photos = "photos"
}
