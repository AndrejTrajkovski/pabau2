import Foundation
import ChooseLocation
import ChooseEmployees

public enum ChooseLocationAndEmployeeAction: Equatable {
	case onChooseLocation
	case onChooseEmployee
	case chooseLocation(ChooseLocationAction)
	case chooseEmployee(ChooseEmployeesAction)
}
