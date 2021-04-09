import SwiftUI
import Util
import Model
import ComposableArchitecture

public struct JourneyFilter: View {
	let store: Store<JourneyFilterState, JourneyFilterAction>
	@ObservedObject var viewStore: ViewStore<State, JourneyFilterAction>

	struct State: Equatable {
		let employees: IdentifiedArrayOf<Employee>
		let selectedIds: Set<Employee.Id>
		init(state: JourneyFilterState) {
			self.employees = state.employees[state.locationId] ?? []
			self.selectedIds = state.selectedEmployeesIds
		}
	}
	
	public init(_ store: Store<JourneyFilterState, JourneyFilterAction>) {
		self.store = store
		print("JourneyFilter viewStore:")
		print(ViewStore(store).state)
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
		print("JourneyFilter employees2:")
		print(self.viewStore.state.employees)
	}

	public var body: some View {
		print("JourneyFilter")
		return EmployeeList(selectedEmployeesIds: self.viewStore.state.selectedIds,
					 employees: self.viewStore.state.employees,
					 header: EmployeeHeader {
						withAnimation {
							self.viewStore.send(.toggleEmployees)
						}
					 },
					 didSelectEmployee: { self.viewStore.send(.onTapGestureEmployee($0))}
		)
		.frame(width: 302)
		.background(Color.white.shadow(color: .employeeShadow, radius: 40.0, x: -20, y: 2))
	}
}

private struct EmployeeList: View {
	public let selectedEmployeesIds: Set<Employee.Id>
	public let employees: IdentifiedArrayOf<Employee>
	public let header: EmployeeHeader
	public let didSelectEmployee: (Employee) -> Void
	public var body: some View {
		//wrapping in Form for color (https://stackoverflow.com/a/57468607/3050624)
		Form {
			List {
				Section(header: header) {
					ForEach(employees) { employee in
						EmployeeRow(employee: employee,
												isSelected: self.selectedEmployeesIds.contains(employee.id)) {
													self.didSelectEmployee($0)
						}
					}
				}
			}
		}.background(Color.employeeBg)
	}
}

private struct EmployeeRow: View {
	let employee: Employee
	let isSelected: Bool
	let didSelectEmployee: (Employee) -> Void
	var body: some View {
		HStack {
			Image(systemName: self.isSelected ? "checkmark.circle.fill" : "circle")
				.foregroundColor(self.isSelected ? Color.deepSkyBlue : Color.gray192)
			Text(employee.name)
		}.onTapGesture {
			self.didSelectEmployee(self.employee)
		}.listRowBackground(Color.employeeBg)
	}
}
