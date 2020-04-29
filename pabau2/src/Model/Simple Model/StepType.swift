//
// StepType.swift

import Foundation

public enum StepType: String, Codable, Equatable {
	case patientdetails = "patientDetails"
	case medicalhistory = "medicalHistory"
	case consents = "consents"
	case checkpatient = "checkPatient"
	case treatmentnotes = "treatmentNotes"
	case prescriptions = "prescriptions"
	case photos = "photos"
	case recalls = "recalls"
	case aftercares = "aftercares"
//	case mediaimages = "mediaImages"
//	case mediavideos = "mediaVideos"
	
	public var title: String {
		switch self {
		case .patientdetails:
			return "Check Details"
		case .medicalhistory:
			return "Medical History"
		case .consents:
			return "Consents"
		case .checkpatient:
			return "Check Details"
		case .treatmentnotes:
			return "Treatment Notes"
		case .prescriptions:
			return "Prescriptions"
		case .photos:
			return "Photos"
		case .recalls:
			return "Recall"
		case .aftercares:
			return "Aftercare"
//		case .mediaimages:
//			return "Image"
//		case .mediavideos:
//			return "Video"
		}
	}
}
