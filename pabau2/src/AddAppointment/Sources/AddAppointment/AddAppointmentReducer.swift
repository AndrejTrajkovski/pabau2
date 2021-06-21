import ComposableArchitecture
import Model
import SharedComponents
import ChooseLocationAndEmployee
import AlertToast
import ToastAlert
import Util

let addAppTapBtnReducer = Reducer<
	AddAppointmentState?,
	AddAppointmentAction,
	AddAppointmentEnv
> { state, action, _ in
	switch action {
	case .closeBtnTap:
		state = nil
	case .appointmentCreated(let result):
		state?.showsLoadingSpinner = false
		switch result {
		case .success(let services):
            state?.toast = ToastState(mode: .banner(.slide),
                                     type: .regular,
                                     title: Texts.appointmentSuccessfullyCreated)
            return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                .map { _ in AddAppointmentAction.dismissToastSuccess }
		case .failure(let error):
            print("failure")
            state?.toast = ToastState(mode: .alert,
                                     type: .error(.red),
                                     title: error.description)
            
            return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                .map { _ in AddAppointmentAction.dismissToast }
		}
    case .dismissToast:
        state?.toast = nil
        return .cancel(id: ToastTimerId())
    case .dismissToastSuccess:
        state = nil
        return .cancel(id: ToastTimerId())
	default:
		break
	}
	return .none
}

let addAppointmentValueReducer: Reducer<AddAppointmentState, AddAppointmentAction, AddAppointmentEnv> =
    .combine(
		chooseClientsReducer.pullback(
			state: \AddAppointmentState.clients,
			action: /AddAppointmentAction.clients,
			environment: { $0 }),
		chooseServiceReducer.pullback(
			state: \AddAppointmentState.services,
			action: /AddAppointmentAction.services,
			environment: { $0 }),
		SingleChoiceLinkReducer<Duration>().reducer.pullback(
			state: \AddAppointmentState.durations,
			action: /AddAppointmentAction.durations,
			environment: { $0 }),
		chooseLocationAndEmployeeReducer.pullback(
			state: \AddAppointmentState.chooseLocAndEmp,
			action: /AddAppointmentAction.chooseLocAndEmp,
			environment: makeChooseLocAndEmpEnv(_:)),
		chooseParticipantReducer.pullback(
			state: \AddAppointmentState.participants,
			action: /AddAppointmentAction.participants,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.isAllDay,
			action: /AddAppointmentAction.isAllDay,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.sms,
			action: /AddAppointmentAction.sms,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.reminder,
			action: /AddAppointmentAction.reminder,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.feedback,
			action: /AddAppointmentAction.feedback,
			environment: { $0 }),
		switchCellReducer.pullback(
			state: \AddAppointmentState.email,
			action: /AddAppointmentAction.email,
			environment: { $0 }),
		textFieldReducer.pullback(
			state: \AddAppointmentState.note,
			action: /AddAppointmentAction.note,
			environment: { $0 }),
	.init { state, action, env in
		switch action {
		case .saveAppointmentTap:
			
			var isValid = true
			
			if state.clients.chosenClient?.fullname == nil {
				state.chooseClintValidator = "Client is required."
				isValid = false
			}
			
			if state.services.chosenService?.name == nil {
				state.chooseServiceValidator = "Service is required."
				isValid = false
			}
			
			let isLocAndEmpValid = state.chooseLocAndEmp.validate()
			
			isValid = isValid && isLocAndEmpValid
			
			if !isValid { break }
			
			state.showsLoadingSpinner = true
			
			return env.clientAPI.createAppointment(appointment: state.appointmentsBody)
				.catchToEffect()
				.receive(on: DispatchQueue.main)
				.map(AddAppointmentAction.appointmentCreated)
				.eraseToEffect()
			
			case .services(.didSelectService(_)):
			
				state.chooseServiceValidator = nil
			
			case .clients(.didSelectClient(_)):
				
				state.chooseClintValidator = nil
				
			case .didTapServices:
				
				state.services.isChooseServiceActive = true
				
			case .didTabClients:
				
				state.clients.isChooseClientsActive = true
				
			case .didTapParticipants:
				
				guard state.isAllDay,
					  let location = state.chooseLocAndEmp.chosenLocationId,
					  let service = state.services.chosenService,
					  let employee = state.chooseLocAndEmp.chosenEmployeeId
				else {
					state.alertBody = AlertBody(
						title: "Info",
						subtitle: "Please choose Service, Location and Employee",
						primaryButtonTitle: "",
						secondaryButtonTitle: "Ok",
						isShow: true
					)
					break
				}

				state.participants.participantSchema = ParticipantSchema(
					id: UUID(),
					isAllDays: state.isAllDay,
					locationId: location,
					serviceId: service.id,
					employeeId: employee
				)

				state.participants.isChooseParticipantActive = true
			case .removeChosenParticipant:
				state.participants.chosenParticipants = []
			case .cancelAlert:
				state.alertBody = nil
			case .chooseStartDate(let startDate):
				state.startDate = startDate
			default:
				break
			}
			return .none
		}
	)

public let addAppointmentReducer: Reducer<AddAppointmentState?, AddAppointmentAction, AddAppointmentEnv> =
    .combine(
	addAppointmentValueReducer.optional().pullback(
		state: \AddAppointmentState.self,
		action: /AddAppointmentAction.self,
		environment: { $0 }),
	addAppTapBtnReducer.pullback(
		state: \AddAppointmentState.self,
		action: /AddAppointmentAction.self,
		environment: { $0 })
)
