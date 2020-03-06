//
// PhotoDetails.swift

import Foundation


public struct PhotoDetails: Codable {

    public let url: String
    public let dateTaken: Date?
    
    public enum CodingKeys: String, CodingKey { 
        case url
        case dateTaken = "date_taken"
    }

}
