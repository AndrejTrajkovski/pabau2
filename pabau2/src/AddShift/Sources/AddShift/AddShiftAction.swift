import SharedComponents
import ChooseLocationAndEmployee
import Model
import Foundation

public enum AddShiftAction {
	case isPublished(ToggleAction)
	case chooseLocAndEmp(ChooseLocationAndEmployeeAction)
	case shiftCreated(Result<Shift, RequestError>)
	case startDate(Date?)
	case startTime(Date?)
	case endTime(Date?)
	case note(TextChangeAction)
	case saveShift
	case close
}
