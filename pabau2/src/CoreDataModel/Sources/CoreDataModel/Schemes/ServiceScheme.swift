import CoreStore
import Model
import Util

public class ServiceScheme: CoreStoreObject {
    @Field.Stored("id")
    public var id: String = ""

    @Field.Stored("name")
    public var name: String = ""

    @Field.Stored("color")
    public var color: String = ""

    @Field.Stored("categoryName")
    public var categoryName: String = ""

    @Field.Stored("disabledUsers")
    public var disabledUsers: String = ""

    @Field.Stored("duration")
    public var duration: String = ""
}

extension Service {
    public static func convert(from schemes: [ServiceScheme]) -> [Service] {
        schemes.compactMap {
            Service(
                id: $0.id,
                name: $0.name,
                color: $0.color,
                categoryName: $0.categoryName,
                disabledUsers: $0.disabledUsers,
                duration: $0.duration
            )
        }
    }

    public func save(to store: CoreDataModel) {
        store.dataStack.perform { (transaction) -> ServiceScheme in
            let scheme = transaction.create(Into<ServiceScheme>())
            scheme.id = self.id.description
            scheme.name = self.name
            scheme.color = self.color ?? ""
            scheme.categoryName = self.categoryName ?? ""
            scheme.disabledUsers = self.disabledUsers ?? ""
            scheme.duration = self.duration ?? ""
            return scheme
        } completion: { (result) in
            log(result, text: "ServiceScheme created")
        }
    }
}
