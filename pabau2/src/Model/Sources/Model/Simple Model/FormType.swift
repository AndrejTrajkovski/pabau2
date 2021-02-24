//
// FormType.swift

import Foundation

public enum FormType: String, Codable, Equatable {
	case history = "history"
	case treatment = "treatment"
	case consent = "consent"
	case prescription = "prescription"
	case epaper
    case unknown
//	case photos = "photos"
}
