//
// Postcare.swift

import Foundation

public struct Postcare: Codable, Identifiable {

    public let id: Int

    public let clientId: Int

    public let employeeId: Int

    public let journeyId: Int?

    public let template: PostcareTemplate?
    public init(id: Int, clientId: Int, employeeId: Int, journeyId: Int? = nil, template: PostcareTemplate? = nil) {
        self.id = id
        self.clientId = clientId
        self.employeeId = employeeId
        self.journeyId = journeyId
        self.template = template
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case clientId = "clientid"
        case employeeId = "employeeid"
        case journeyId = "journeyid"
        case template
    }

}
