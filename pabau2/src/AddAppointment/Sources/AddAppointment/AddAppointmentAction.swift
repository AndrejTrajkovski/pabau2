import SharedComponents
import Model
import Foundation

import ChooseLocationAndEmployee
public enum AddAppointmentAction: Equatable {
	case saveAppointmentTap
	case addAppointmentDismissed
	case chooseStartDate(Date)
	case clients(ChooseClientsAction)
	case services(ChooseServiceAction)
	case participants(ChooseParticipantAction)
	case durations(SingleChoiceLinkAction<Duration>)
	case chooseLocAndEmp(ChooseLocationAndEmployeeAction)
	case didTapParticipants
	case closeBtnTap
	case didTapServices
	case didTapWith
	case didTabClients
	case removeChosenParticipant
	case isAllDay(ToggleAction)
	case sms(ToggleAction)
	case reminder(ToggleAction)
	case email(ToggleAction)
	case feedback(ToggleAction)
	case note(TextChangeAction)
    case appointmentCreated(Result<CalendarEvent, RequestError>)
	case cancelAlert
    case dismissToast
    case dismissToastSuccess
}
