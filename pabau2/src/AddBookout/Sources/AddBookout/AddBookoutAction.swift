import Model
import Util
import SharedComponents
import Foundation
import ChooseLocationAndEmployee

public enum AddBookoutAction {
	case chooseStartDate(Date?)
	case chooseTime(Date?)
	case chooseLocAndEmp(ChooseLocationAndEmployeeAction)
    case chooseDuration(SingleChoiceLinkAction<Duration>)
    case choosePredefinedDuration(SingleChoiceActions<Duration>)
	case chooseBookoutReason(ChooseBookoutReasonAction)
	case onChooseBookoutReason
	case isPrivate(ToggleAction)
	case isAllDay(ToggleAction)
	case note(TextChangeAction)
	case description(TextChangeAction)
	case close
	case saveBookout
    case appointmentCreated(Result<CalendarEvent, RequestError>)
    case dismissToast
}
