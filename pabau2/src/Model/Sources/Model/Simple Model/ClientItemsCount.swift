//
//  ClientCardCounter.swift
//

import Foundation

public struct ClientItemsCount: Codable, Equatable {
    public let appointments: Int
    public let financials: Int
    public let packages: Int
    public let communication: Int
    public let treatments: Int
    public let medicalHistory: Int
    public let prescriptions: Int
    public let giftvoucher: Int
    public let loyalty: Int
    public let consents: Int
    public let recall: Int
    public let labtestsRequest: Int
    public let vaccineHistory: Int
    public let pathways: Int
    public let documents: Int
    public let emr: Int
    public let photos: Int
    public let alerts: Int
    public let notes: Int
    
    public enum CodingKeys: String, CodingKey {
        case appointments
        case financials
        case packages
        case communication
        case treatments
        case medicalHistory = "medical_history"
        case prescriptions
        case giftvoucher
        case loyalty
        case consents
        case recall
        case labtestsRequest = "lab_tests_request"
        case vaccineHistory = "vaccine_history"
        case pathways
        case documents
        case emr
        case photos
        case alerts
        case notes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        appointments = try container.decode(Int.self, forKey: .appointments)
        financials = try container.decode(Int.self, forKey: .financials)
        packages = try container.decode(Int.self, forKey: .packages)
        communication = try container.decode(Int.self, forKey: .communication)
        treatments = try container.decode(Int.self, forKey: .treatments)
        medicalHistory = try container.decode(Int.self, forKey: .medicalHistory)
        prescriptions = try container.decode(Int.self, forKey: .prescriptions)
        giftvoucher = try container.decode(Int.self, forKey: .giftvoucher)
        loyalty = try container.decode(Int.self, forKey: .loyalty)
        consents = try container.decode(Int.self, forKey: .consents)
        recall = try container.decode(Int.self, forKey: .recall)
        labtestsRequest = try container.decode(Int.self, forKey: .labtestsRequest)
        vaccineHistory = try container.decode(Int.self, forKey: .vaccineHistory)
        pathways = try container.decode(Int.self, forKey: .pathways)
        documents = try container.decode(Int.self, forKey: .documents)
        emr = try container.decode(Int.self, forKey: .emr)
        photos = try container.decode(Int.self, forKey: .photos)
        alerts = try container.decode(Int.self, forKey: .alerts)
        notes = try container.decode(Int.self, forKey: .notes)
    }
}
