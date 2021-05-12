import CoreStore
import Model

public class BookoutReasonScheme: CoreStoreObject {
    @Field.Stored("id")
    public var id: Int = 0
    
    @Field.Stored("name")
    public var name: String = ""

    @Field.Stored("color")
    public var color: String = ""
}

extension BookoutReason {
    public static func convert(from schemes: [BookoutReasonScheme]) -> [BookoutReason] {
        schemes.compactMap {
             BookoutReason(id: $0.id, name: $0.name, color: $0.color)
        }
    }
    
    public func save(to store: CoreDataModel)  {
        store.dataStack.perform { (transaction) -> BookoutReasonScheme? in
            let scheme = transaction.create(Into<BookoutReasonScheme>())
            scheme.id = self.id
            scheme.name = self.name ?? ""
            scheme.color = self.color ?? ""
            return scheme
        } completion: { (result) in
            print(result, "BookoutReasonScheme created")
        }
    }
}
