//
// BookoutReason.swift

import Foundation
import CoreStore
import ComposableArchitecture
import Tagged

public struct BookoutReason: Decodable, Identifiable, Equatable {
    public var id: Int = 0
    public let name: String?
    public let color: String?
    
    public init(
        id: Int,
        name: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = Int(id) ?? 0
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "room_name"
        case color = "block_color"
    }
}

public class BookoutReasonScheme: CoreStoreObject {
    @Field.Stored("id")
    public var id: Int = 0
    
    @Field.Stored("name")
    public var name: String = ""
    
    @Field.Stored("color")
    public var color: String = ""
}


extension BookoutReason {
    public func save(to store: CoreDataStorage)  {
        store.dataStack.perform { (transaction) -> BookoutReasonScheme? in
            let scheme = transaction.create(Into<BookoutReasonScheme>())
            scheme.id = self.id
            scheme.name = self.name ?? ""
            scheme.color = self.color ?? ""
            return scheme
        } completion: { (result) in
            #if DEBUG
            print(result, "BookoutReasonScheme created")
            #endif
        }
    }
}
