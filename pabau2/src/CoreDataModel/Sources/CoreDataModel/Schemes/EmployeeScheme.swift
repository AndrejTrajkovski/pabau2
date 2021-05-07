import CoreStore
import Model
import Util

public class IDsScheme: CoreStoreObject {
    @Field.Relationship("master")
    var masterEmployeeScheme: EmployeeScheme?
    
    @Field.Stored("id")
    public var id: String = ""
}

public class EmployeeScheme: CoreStoreObject {
    
    @Field.Stored("id")
    public var id: String = ""

    @Field.Stored("full_name")
    public var name: String = ""

    @Field.Stored("email")
    public var email: String = ""

    @Field.Stored("avatar")
    public var avatar: String = ""

    @Field.Relationship("locations", inverse: \IDsScheme.$masterEmployeeScheme)
    var locations: Set<IDsScheme>

    @Field.Stored("passcode")
    public var passcode: String = ""
}

extension Employee {
    public func save(to store: CoreDataModel)  {
        store.dataStack.perform { (transaction) -> EmployeeScheme? in
            let employeeScheme = transaction.create(Into<EmployeeScheme>())
            employeeScheme.id = self.id.description
            employeeScheme.name = self.name
            employeeScheme.email = self.email
            employeeScheme.avatar = self.avatar ?? ""
            let idsShemes: [IDsScheme] = self.locations.compactMap {
                let scheme = transaction.create(Into<IDsScheme>())
                scheme.id = $0.description
                scheme.masterEmployeeScheme = employeeScheme
                return scheme
            }
          
            employeeScheme.locations = Set(idsShemes)
            employeeScheme.passcode = self.passcode
            return employeeScheme
        } completion: { (result) in
            log(result, text: "LocationScheme created")
        }
    }
}
