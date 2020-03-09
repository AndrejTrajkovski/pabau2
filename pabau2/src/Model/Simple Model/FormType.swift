//
// FormType.swift

import Foundation

public enum FormType: String, Codable {
    case history = "history"
    case questionnaire = "questionnaire"
    case treatment = "treatment"
    case consent = "consent"
    case prescription = "prescription"
}