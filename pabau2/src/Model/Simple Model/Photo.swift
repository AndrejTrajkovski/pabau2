//
// Photo.swift

import Foundation


public struct Photo: Codable, Identifiable {


    public let url: String

    public let dateTaken: Date?

    public let id: Int

    public let clientId: Int

    public let employeeId: Int

    public let journeyId: Int?
    public init(url: String, dateTaken: Date? = nil, id: Int, clientId: Int, employeeId: Int, journeyId: Int? = nil) {
        self.url = url
        self.dateTaken = dateTaken
        self.id = id
        self.clientId = clientId
        self.employeeId = employeeId
        self.journeyId = journeyId
    }
    public enum CodingKeys: String, CodingKey { 
        case url
        case dateTaken = "date_taken"
        case id = "id"
        case clientId = "clientid"
        case employeeId = "employeeid"
        case journeyId = "journeyid"
    }

}
