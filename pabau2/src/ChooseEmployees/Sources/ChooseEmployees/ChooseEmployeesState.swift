import ComposableArchitecture
import Model

public struct ChooseEmployeesState: Equatable {
	public var isChooseEmployeesActive: Bool = false
	public var employees: IdentifiedArrayOf<Employee> = []
	public var filteredEmployees: IdentifiedArrayOf<Employee> = []
	public var chosenEmployee: Employee?
	public var searchText: String = "" {
		didSet {
			isSearching = !searchText.isEmpty
		}
	}
	public var isSearching = false

	public init(chosenEmployee: Employee?) {
		self.chosenEmployee = chosenEmployee
	}
}
