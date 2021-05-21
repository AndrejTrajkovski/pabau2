import Model
import Util
import SharedComponents
import Foundation
import ChooseLocation
import ChooseEmployees

public enum AddBookoutAction {
	case chooseStartDate(Date?)
	case chooseTime(Date?)
	case chooseEmployeesAction(ChooseEmployeesAction)
	case onChooseEmployee
	case chooseDuration(SingleChoiceActions<Duration>)
	case chooseLocation(ChooseLocationAction)
	case chooseBookoutReason(ChooseBookoutReasonAction)
	case onChooseLocation
	case onChooseBookoutReason
	case isPrivate(ToggleAction)
	case isAllDay(ToggleAction)
	case note(TextChangeAction)
	case description(TextChangeAction)
	case close
	case saveBookout
	case appointmentCreated(Result<PlaceholdeResponse, RequestError>)
	case ignore
}
