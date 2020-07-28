import SwiftUI
import UtilPackage
import ModelPackage
import ComposableArchitecture

public struct EmployeesListStore: View {
	let store: Store<EmployeesState, EmployeesAction>
	@ObservedObject var viewStore: ViewStore<EmployeesState, EmployeesAction>
	public init(_ store: Store<EmployeesState, EmployeesAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
		print("EmployeesListStore init")
	}
	public var body: some View {
		print("EmployeesListStore body")
		return EmployeeList(selectedEmployeesIds: self.viewStore.state.selectedEmployeesIds,
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

struct EmployeeList: View {
	public let selectedEmployeesIds: Set<Int>
	public let employees: [Employee]
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

struct EmployeeRow: View {
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

struct EmployeeHeader: View {
	let didTouchHeaderButton: () -> Void
	var body: some View {
		HStack {
			Button (action: {
				self.didTouchHeaderButton()
			}, label: {
				Image(systemName: "person").font(.system(size: 28))
			})
			Text(Texts.employee)
				.foregroundColor(.black)
				.font(Font.semibold20)
		}
		.padding(.bottom)
		.background(Color.employeeBg)
	}
}
