import Util
import Model
import ComposableArchitecture

public struct JourneyFilterState: Equatable {
	var loadingState: LoadingState = .initial
	var employees: [Employee] = []
	public var selectedEmployeesIds: Set<Employee.Id> = Set()
	public var isShowingEmployees: Bool = false
	public init() {}
}
