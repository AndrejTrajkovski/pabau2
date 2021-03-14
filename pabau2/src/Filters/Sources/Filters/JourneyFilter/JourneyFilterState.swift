import Util
import Model
import ComposableArchitecture

public struct JourneyFilterState: Equatable {
	public let locationId: Location.Id
	public let employees: [Location.ID: IdentifiedArrayOf<Employee>]
	public var employeesLoadingState: LoadingState
	public var selectedEmployeesIds: Set<Employee.ID>
	public var isShowingEmployees: Bool

	public init(
		locationId: Location.Id,
		employeesLoadingState: LoadingState,
		employees: [Location.ID: IdentifiedArrayOf<Employee>],
		selectedEmployeesIds: Set<Employee.ID>,
		isShowingEmployees: Bool
	) {
		self.locationId = locationId
		self.employeesLoadingState = employeesLoadingState
		self.employees = employees
		self.selectedEmployeesIds = selectedEmployeesIds
		self.isShowingEmployees = isShowingEmployees
	}
}
