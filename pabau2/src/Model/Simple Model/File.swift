//
// File.swift

import Foundation


public struct File: Codable, Identifiable {
    
    public let id: Int
    public let fileData: Data?
    public let fileName: String?
    public let name: String?
}
