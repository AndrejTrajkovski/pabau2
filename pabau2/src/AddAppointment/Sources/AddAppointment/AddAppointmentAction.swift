import SharedComponents
import Model
import Foundation

public enum AddAppointmentAction: Equatable {
	case saveAppointmentTap
	case addAppointmentDismissed
	case chooseStartDate(Date)
	case clients(ChooseClientsAction)
	case services(ChooseServiceAction)
	case participants(ChooseParticipantAction)
	case durations(SingleChoiceLinkAction<Duration>)
	case with(ChooseEmployeesAction)
	case chooseLocation(ChooseLocationAction)
	case onChooseLocation
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
	case appointmentCreated(Result<PlaceholdeResponse, RequestError>)
	case cancelAlert
	case ignore
}
