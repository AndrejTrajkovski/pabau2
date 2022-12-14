import Model
import SharedComponents
import ToastAlert
import ChoosePathway
import PathwayList

public enum AppDetailsAction {
	case buttons(AppDetailsButtonsAction)
	case chooseStatus(SingleChoiceLinkAction<AppointmentStatus>)
	case chooseCancelReason(SingleChoiceLinkAction<CancelReason>)
	case addService
	case chooseRepeat(ChooseRepeatAction)
	case close
	case downloadStatusesResponse(Result<[AppointmentStatus], RequestError>)
    case onDownloadCancelReasons(Result<[CancelReason], RequestError>)
    case onResponseChangeCancelReason(Result<CalendarEvent.Id, RequestError>)
	case onResponseChangeAppointment(Result<VoidAPIResponse, RequestError>)
	case onResponseCreateReccuringAppointment(Result<Bool, RequestError>)
    case onResponseRescheduleAppointment(Result<CalendarEvent.Id, RequestError>)
	case dismissToast
    case chooseReschedule(ChooseRescheduleAction)
	case choosePathwayTemplate(ChoosePathwayContainerAction)
	case choosePathway(PathwayListAction)
	case backFromChooseTemplates
	case backFromPathwaysList
}
