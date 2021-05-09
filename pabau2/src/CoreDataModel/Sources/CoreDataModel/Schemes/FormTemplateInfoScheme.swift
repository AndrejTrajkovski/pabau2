import CoreStore
import Model
import Util

public class FormTemplateInfoScheme: CoreStoreObject {
    @Field.Stored("id")
    public var id: String = ""
    
    @Field.Stored("name")
    public var name: String = ""
    
    @Field.Stored("color")
    public var type: String = ""
}

extension FormTemplateInfo {
    public func save(to store: CoreDataModel)  {
        store.dataStack.perform { (transaction) -> FormTemplateInfoScheme? in
            let scheme = transaction.create(Into<FormTemplateInfoScheme>())
            scheme.id = self.id.description
            scheme.name = self.name
            scheme.type = self.type.rawValue
            return scheme
        } completion: { (result) in
            log(result, text: "LocationScheme created")
        }
    }
}