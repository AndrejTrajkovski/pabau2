//
// FormType.swift

import Foundation

public enum FormType: String, Codable, Equatable {
	case history = "questionnaire"
	case treatment = "treatment"
	case consent = "consent"
	case prescription = "prescription"
	case epaper
    case unknown
	
	public init?(stepType: StepType) {
		switch stepType {
		case .medicalhistory:
			self = .history
		case .consents:
			self = .consent
		case .treatmentnotes:
			self = .treatment
		case .prescriptions:
			self = .prescription
        case .checkpatient, .patientdetails, .photos, .aftercares, .lab, .video, .timeline:
			return nil
        }
	}
}
