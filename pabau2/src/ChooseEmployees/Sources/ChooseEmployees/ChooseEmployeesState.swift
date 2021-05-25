import ComposableArchitecture
import Model

public struct ChooseEmployeesState: Equatable {
	public var employees: IdentifiedArrayOf<Employee>
	public var filteredEmployees: IdentifiedArrayOf<Employee>
	public var chosenEmployeeId: Employee.Id?
	
	public var chosenEmployee: Employee? {
		return chosenEmployeeId.flatMap {
			employees[id: $0]
		}
	}
	
	public var searchText: String = ""

	public init(chosenEmployeeId: Employee.Id?,
				employees: IdentifiedArrayOf<Employee>) {
		self.chosenEmployeeId = chosenEmployeeId
		self.employees = employees
		self.filteredEmployees = employees
	}
}
