import Util
import Model
import ComposableArchitecture

public struct JourneyFilterState: Equatable {
	public let locationId: Location.Id
	public var employeesLoadingState: LoadingState
	public var employees: IdentifiedArrayOf<Employee>
	public var selectedEmployeesIds: Set<Employee.Id>
	public var isShowingEmployees: Bool
	
	public init(
		locationId: Location.Id,
		employeesLoadingState: LoadingState,
		employees: IdentifiedArrayOf<Employee>,
		selectedEmployeesIds: Set<Employee.Id>,
		isShowingEmployees: Bool
	) {
		self.locationId = locationId
		self.employeesLoadingState = employeesLoadingState
		self.employees = employees
		self.selectedEmployeesIds = selectedEmployeesIds
		self.isShowingEmployees = isShowingEmployees
	}
	
	public func selectedEmployees() -> IdentifiedArrayOf<Employee> {
		employees.filter { selectedEmployeesIds.contains($0.id) }
	}
}
