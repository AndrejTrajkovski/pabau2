//
// StepType.swift

import Foundation

public enum StepType: String, Codable, Equatable, CaseIterable {
	case patientdetails = "patientDetails"
	case medicalhistory = "medicalHistory"
	case consents = "consents"
	case checkpatient = "checkPatient"
	case treatmentnotes = "treatmentNotes"
	case prescriptions = "prescriptions"
	case photos = "photos"
	case aftercares = "aftercares"
	case patientComplete = "complete"
//	case mediaimages = "mediaImages"
//	case mediavideos = "mediaVideos"

	public var order: Int {
		switch self {
		case .patientdetails:
			return 0
		case .medicalhistory:
			return 1
		case .consents:
			return 2
		case .checkpatient:
			return 3
		case .treatmentnotes:
			return 4
		case .prescriptions:
			return 5
		case .photos:
			return 6
		case .aftercares:
			return 7
		case .patientComplete:
			return 8
		}
	}
	
	public var title: String {
		switch self {
		case .patientdetails:
			return "Enter Patient Details"
		case .medicalhistory:
			return "Medical History"
		case .consents:
			return "Consents"
		case .checkpatient:
			return "Check Patient Details"
		case .treatmentnotes:
			return "Treatment Notes"
		case .prescriptions:
			return "Prescriptions"
		case .photos:
			return "Photos"
		case .aftercares:
			return "Aftercare"
//		case .mediaimages:
//			return "Image"
//		case .mediavideos:
//			return "Video"
		case .patientComplete:
			return "Complete"
		}
	}
}
