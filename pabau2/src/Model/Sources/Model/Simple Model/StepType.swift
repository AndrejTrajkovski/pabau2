//
// StepType.swift

import Foundation

public enum StepType: String, Codable, Equatable, CaseIterable, Identifiable {
	public var id: String { rawValue }
	
	case patientdetails = "details"
	case medicalhistory = "questionnaire"
	case consents = "consent"
	case treatmentnotes = "treatment"
	case prescriptions = "prescription"
	case photos = "photo"
	case aftercares = "aftercare"
    case lab
    case video
    case timeline
    
	public var title: String {
		switch self {
		case .patientdetails:
			return "Enter Patient Details"
		case .medicalhistory:
			return "Medical History"
		case .consents:
			return "Consents"
		case .treatmentnotes:
			return "Treatment Notes"
		case .prescriptions:
			return "Prescriptions"
		case .photos:
			return "Photos"
		case .aftercares:
			return "Aftercare"
        case .lab:
            return "Lab"
        case .video:
            return "Video"
        case .timeline:
            return "Timeline"
        }
	}
}
