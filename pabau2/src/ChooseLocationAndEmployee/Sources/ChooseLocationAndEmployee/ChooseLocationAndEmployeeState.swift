import Model
import ComposableArchitecture
import ChooseLocation
import ChooseEmployees

public struct ChooseLocationAndEmployeeState: Equatable {
	
	public init(locations: IdentifiedArrayOf<Location>, employees: [Location.Id: IdentifiedArrayOf<Employee>], chosenLocationId: Location.Id? = nil, chosenEmployeeId: Employee.Id? = nil, locationValidationError: String? = nil, employeeValidationError: String? = nil, chooseLocationState: ChooseLocationState? = nil, chooseEmployeeState: ChooseEmployeesState? = nil) {
		self.locations = locations
		self.employees = employees
		self.chosenLocationId = chosenLocationId
		self.chosenEmployeeId = chosenEmployeeId
		self.locationValidationError = locationValidationError
		self.employeeValidationError = employeeValidationError
		self.chooseLocationState = chooseLocationState
		self.chooseEmployeeState = chooseEmployeeState
	}
	
	public mutating func validate() -> Bool {
		if chosenLocationId == nil {
			locationValidationError = "Location is required."
		}
		
		if chosenEmployeeId == nil {
			employeeValidationError = "Employee is required."
		}
		
		return chosenLocationId != nil && chosenEmployeeId != nil
	}
	
	public var locations: IdentifiedArrayOf<Location>
	public var employees: [Location.Id: IdentifiedArrayOf<Employee>]
	public var chosenLocationId: Location.Id?
	public var chosenEmployeeId: Employee.Id?
	public var locationValidationError: String?
	public var employeeValidationError: String?
	
	public var chooseLocationState: ChooseLocationState?
	public var chooseEmployeeState: ChooseEmployeesState?
	
	var chosenLocation: Location? {
		chosenLocationId.flatMap {
			locations[id: $0]
		}
	}
	
	var chosenEmployee: Employee? {
		chosenEmployeeId.flatMap {
			guard let chosenLocationId = chosenLocationId,
				  let empInLoc = employees[chosenLocationId] else { return nil }
			return empInLoc[id: $0]
		}
	}
	
	init(locations: IdentifiedArrayOf<Location>,
		 employees: [Location.ID: IdentifiedArrayOf<Employee>],
		 chosenLocationId: Location.Id? = nil,
		 chosenEmployeeId: Employee.Id? = nil
	) {
		self.locations = locations
		self.employees = employees
		self.chosenLocationId = chosenLocationId
		self.chosenEmployeeId = chosenEmployeeId
	}
}
