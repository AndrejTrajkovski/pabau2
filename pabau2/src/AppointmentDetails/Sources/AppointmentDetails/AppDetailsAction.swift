import Model
import SharedComponents
import ToastAlert

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
}
