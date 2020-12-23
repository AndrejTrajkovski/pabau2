//
// FormDetails.swift

import Foundation

public struct FormDetails: Codable {

    public let template: HTMLFormTemplate

    public let patientStatus: PatientStatus

    public let fieldValues: [FormFieldValue]?

    public enum CodingKeys: String, CodingKey {
        case template
        case patientStatus = "patient_status"
        case fieldValues = "field_values"
    }
}
