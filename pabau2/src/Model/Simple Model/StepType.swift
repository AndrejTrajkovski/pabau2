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
    case mediaimages = "mediaImages"
    case mediavideos = "mediaVideos"
}
