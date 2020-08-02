//
// ClientItemsCount.swift

import Foundation

public struct ClientItemsCount: Codable, Identifiable, Equatable {

    public let id: Int

    public let appointments: Int

    public let photos: Int

    public let financials: Int

    public let treatmentNotes: Int

    public let presriptions: Int

    public let documents: Int

    public let communications: Int

    public let consents: Int

    public let alerts: Int

    public let notes: Int
    public init(id: Int, appointments: Int, photos: Int, financials: Int, treatmentNotes: Int, presriptions: Int, documents: Int, communications: Int, consents: Int, alerts: Int, notes: Int) {
        self.id = id
        self.appointments = appointments
        self.photos = photos
        self.financials = financials
        self.treatmentNotes = treatmentNotes
        self.presriptions = presriptions
        self.documents = documents
        self.communications = communications
        self.consents = consents
        self.alerts = alerts
        self.notes = notes
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case appointments
        case photos
        case financials
        case treatmentNotes
        case presriptions
        case documents
        case communications
        case consents
        case alerts
        case notes
    }

}
