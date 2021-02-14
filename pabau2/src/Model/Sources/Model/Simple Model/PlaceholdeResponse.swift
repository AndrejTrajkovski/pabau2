//
//  PlaceholdeResponse.swift
//  
//
//  Created by Yuriy Berdnikov on 10.02.2021.
//

import Foundation

public struct PlaceholdeResponse: Equatable, Codable {
    public let success: Bool
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}
