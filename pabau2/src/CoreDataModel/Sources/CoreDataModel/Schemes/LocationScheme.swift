import CoreStore
import Model
import Util

public class LocationScheme: CoreStoreObject {
    @Field.Stored("id")
    public var id: String = ""
    
    @Field.Stored("name")
    public var name: String = ""
    
    @Field.Stored("color")
    public var color: String = ""
}

extension Location {
    public static func convert(from schemes: [LocationScheme]) -> [Location] {
        schemes.compactMap {
            Location(id: $0.id, name: $0.name, color: $0.color)
        }
    }
    
    public func save(to store: CoreDataModel) {
        store.dataStack.perform { (transaction) -> LocationScheme? in
            let scheme = transaction.create(Into<LocationScheme>())
            scheme.id = self.id.description
            scheme.name = self.name
            scheme.color = self.color ?? ""
            return scheme
        } completion: { (result) in

            log(result, text: "LocationScheme created")
        }
    }
}
