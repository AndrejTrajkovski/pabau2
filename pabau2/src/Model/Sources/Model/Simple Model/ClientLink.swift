//
// ClientLink.swift

import Foundation

/** Object representing a link between an entity and a client (and optionally a journey too). Used in  composition with Photo, Form, Aftercare and Recall. */
public struct ClientLink: Codable, Identifiable {

    public let id: Int

    public let clientId: Int

    public let employeeId: Int

    public let journeyId: Int?
    public init(id: Int, clientId: Int, employeeId: Int, journeyId: Int? = nil) {
        self.id = id
        self.clientId = clientId
        self.employeeId = employeeId
        self.journeyId = journeyId
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case clientId = "clientid"
        case employeeId = "employeeid"
        case journeyId = "journeyid"
    }

}
