import CoreStore
import Model
import Util
import Tagged


public class EmployeeScheme: CoreStoreObject {
    public class IDsScheme: CoreStoreObject {
        @Field.Relationship("master")
        var masterEmployeeScheme: EmployeeScheme?

        
        @Field.Stored("id")
        public var id: String = ""
    }
    
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
    public static func convert(from schemes: [EmployeeScheme]) -> [Employee]  {
        schemes.compactMap {
            Employee(
                id: Id(rawValue: $0.id),
                name: $0.name,
                email: $0.email,
                avatar: $0.avatar,
                locations: $0.locations.map { Location.Id(rawValue: EitherStringOrInt.left($0.id)) },
                passcode: $0.passcode
            )
        }
    }
    
    public func save(to store: CoreDataModel)  {
        store.dataStack.perform { (transaction) -> EmployeeScheme? in
            let employeeScheme = transaction.create(Into<EmployeeScheme>())
            employeeScheme.id = self.id.description
            employeeScheme.name = self.name
            employeeScheme.email = self.email
            employeeScheme.avatar = self.avatar ?? ""
            let idsShemes: [EmployeeScheme.IDsScheme] = self.locations.compactMap {
                let scheme = transaction.create(Into<EmployeeScheme.IDsScheme>())
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
