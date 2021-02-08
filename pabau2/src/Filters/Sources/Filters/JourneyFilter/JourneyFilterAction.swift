import Model
import ComposableArchitecture

public enum JourneyFilterAction {
	case toggleEmployees
	case gotResponse(Result<[Employee], RequestError>)
	case onTapGestureEmployee(Employee)
	case reloadEmployees
}
