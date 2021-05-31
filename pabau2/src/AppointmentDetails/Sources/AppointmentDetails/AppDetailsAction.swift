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
	case cancelReasonsResponse(Result<[CancelReason], RequestError>)
	case onResponseChangeAppointment
	case onResponseCreateReccuringAppointment
	case dismissToast
	case choosePathwayTemplate(ChoosePathwayContainerAction)
	case choosePathway(PathwayListAction)
	case backFromChooseTemplates
	case backFromPathwaysList
}
