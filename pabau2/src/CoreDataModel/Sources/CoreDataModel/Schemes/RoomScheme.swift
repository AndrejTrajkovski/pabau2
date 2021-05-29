import CoreStore
import Model
import Util

public class RoomScheme: CoreStoreObject {
    public class IDsScheme: CoreStoreObject {
        @Field.Relationship("master")
        var masterRoomScheme: RoomScheme?
        
        @Field.Stored("id")
        public var id: String = ""
    }
    
    @Field.Stored("id")
    public var id: String = ""
    
    @Field.Stored("name")
    public var name: String = ""
    
    @Field.Stored("color")
    public var color: String = ""
    
    @Field.Relationship("locations", inverse: \IDsScheme.$masterRoomScheme)
    var locations: Set<IDsScheme>
}

extension Room {
    public static func convert(from schemes: [RoomScheme]) -> [Room] {
        schemes.compactMap {
            Room(
                id: Id(rawValue: $0.id),
                name: $0.name,
                locationIds: $0.locations.map { Location.Id(rawValue: EitherStringOrInt.left($0.id)) }
            )
        }
    }
    
    public func save(to store: CoreDataModel) {
        store.dataStack.perform { (transaction) -> RoomScheme? in
            let roomScheme = transaction.create(Into<RoomScheme>())
            roomScheme.id = self.id.description
            roomScheme.name = self.name
            let idsShemes: [RoomScheme.IDsScheme] = self.locationIds.compactMap {
                let scheme = transaction.create(Into<RoomScheme.IDsScheme>())
                scheme.id = $0.description
                scheme.masterRoomScheme = roomScheme
                return scheme
            }
            
            roomScheme.locations = Set(idsShemes)
            return roomScheme
        } completion: { (result) in
            log(result, text: "LocationScheme created")
        }
    }
}

