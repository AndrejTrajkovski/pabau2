import Model
import ComposableArchitecture

public enum EmployeesFilterAction {
	case toggleEmployees
	case gotResponse(Result<[Employee], RequestError>)
	case onTapGestureEmployee(Employee)
	case loadEmployees
}
