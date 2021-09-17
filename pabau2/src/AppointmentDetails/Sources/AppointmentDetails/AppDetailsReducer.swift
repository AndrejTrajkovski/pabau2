import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents
import CoreDataModel
import Foundation
import ToastAlert
import ChoosePathway
import PathwayList
import AlertToast

public let appDetailsReducer: Reducer<AppDetailsState, AppDetailsAction, AppDetailsEnvironment> = .combine(
	appDetailsButtonsReducer.pullback(
		state: \AppDetailsState.itemsState,
		action: /AppDetailsAction.buttons,
		environment: { $0 }
	),
	SingleChoiceLinkReducer<AppointmentStatus>().reducer.pullback(
		state: \AppDetailsState.chooseStatus,
		action: /AppDetailsAction.chooseStatus,
		environment: { $0 }),
	SingleChoiceLinkReducer<CancelReason>().reducer.pullback(
		state: \AppDetailsState.chooseCancelReason,
		action: /AppDetailsAction.chooseCancelReason,
		environment: { $0 }),
	chooseRepeatReducer.pullback(
		state: \AppDetailsState.chooseRepeat,
		action: /AppDetailsAction.chooseRepeat,
		environment: { $0 }),
	choosePathwayContainerReducer.optional().pullback(
		state: \AppDetailsState.choosePathwayTemplate,
		action: /AppDetailsAction.choosePathwayTemplate,
		environment: makeChoosePathwayEnv(_:)
	),
	Reducer.init { state, action, env in
		switch action {
		case .chooseRepeat(.onRepeat(let chosenRepeat)):
			let formatter = DateFormatter()
			formatter.dateFormat = "dd-MM-yyyy"
			let sDate = formatter.string(from: chosenRepeat.date)
			let interval = chosenRepeat.interval.interval
						
			return env.clientsAPI.createRecurringAppointment(appointmentId: state.app.id, repeatRange: interval, repeatUntil: sDate)
				.catchToEffect()
				.map { response in AppDetailsAction.onResponseCreateReccuringAppointment(response) }
		case .onResponseCreateReccuringAppointment(let response):
			state.chooseRepeat.isRepeatActive = false
            switch response {
            case .success(_):
                state.toast = ToastState(mode: .banner(.slide),
                                         type: .regular,
                                         title: "Appointment repeated created.")
            case .failure(let error):
                state.toast = ToastState(mode: .alert,
                                         type: .error(.red),
                                         title: error.description)
            }
            return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                .map { _ in AppDetailsAction.dismissToast }
            
		case .chooseCancelReason(let singleChoiceLinkAction):
			switch singleChoiceLinkAction {
			case .singleChoice(let single):
				switch single {
				case .action(let id, let action):
                    guard let cancelReason = state.cancelReasons[id: id] else {
                        return .none
                    }
                    let appID = state.app.id
                    let cancelReasonId = cancelReason.id.rawValue
                    
                    return env.clientsAPI.appointmentChangeCancelReason(appointmentId: state.app.id, reasonId: cancelReasonId) 
						.catchToEffect()
                        .map { response in
                            let newResponse: Result<Appointment.ID, RequestError>
                            switch response {
                            case .success(_): newResponse = .success(appID)
                            case .failure(let error): newResponse = .failure(error)
                            }
                            return AppDetailsAction.onResponseChangeCancelReason(newResponse)
                        }
						.eraseToEffect()
					
				}
			default:
				break
			}
		case .chooseStatus(let singleChoiceLinkAction):
			switch singleChoiceLinkAction {
			case .singleChoice(let single):
				switch single {
				case .action(let id, let action):
					let status = state.appStatuses[id: id]
                    if let status = status {
                        return env.clientsAPI.appointmentChangeStatus(appointmentId: state.app.id, statusId: status.id)
                            .catchToEffect()
                            .map { response in AppDetailsAction.onResponseChangeAppointment(response) }
                            .eraseToEffect()
                    }
				}
			default:
				break
			}
        case .chooseRepeat(.onBackBtn):
            state.chooseRepeat.isRepeatActive = false
		case .buttons(let appDetailsButtonsAction):
			print(appDetailsButtonsAction)
			switch appDetailsButtonsAction {
			case .onStatus:
				state.isStatusActive = true
				return env.clientsAPI.getAppointmentStatus()
					.catchToEffect()
					.receive(on: DispatchQueue.main)
					.map(AppDetailsAction.downloadStatusesResponse)
					.eraseToEffect()
			case .onCancel:
				state.isCancelActive = true
				return env.clientsAPI.getAppointmentCancelReasons()
					.catchToEffect()
					.receive(on: DispatchQueue.main)
					.map(AppDetailsAction.onDownloadCancelReasons)
					.eraseToEffect()
			case .onRepeat:
                state.chooseRepeat.isRepeatActive = true
			case .onReschedule:
                state.chooseReschedule.isRescheduleActive = true
			case .onPathway:
				if state.app.pathways.isEmpty {
					state.choosePathwayTemplate = ChoosePathwayState(selectedAppointment: state.app)
					return env.journeyAPI.getPathwayTemplates()
						.receive(on: DispatchQueue.main)
						.catchToEffect()
						.map { .choosePathwayTemplate(.gotPathwayTemplates($0))  }

				} else {
					state.isPathwayListActive = true
				}
			}
		case .choosePathway(.addNew):
			state.choosePathwayTemplate = ChoosePathwayState(selectedAppointment: state.app)
			return env.journeyAPI.getPathwayTemplates()
				.receive(on: DispatchQueue.main)
				.catchToEffect()
				.map { .choosePathwayTemplate(.gotPathwayTemplates($0))  }
		case .addService:
			break
		case .chooseRepeat(.onChangeInterval(_)):
			break
		case .chooseRepeat(.onSelectedOkCalendar(_)):
			break
		case .close:
			break
		case .downloadStatusesResponse(let result):
			switch result {
			case .success(let downloadStatuses):
				state.chooseStatusLS = .gotSuccess
                state.appStatuses = IdentifiedArray(uniqueElements: downloadStatuses, id: \AppointmentStatus.id)
			case .failure(let error):
				state.isStatusActive = false
				state.chooseStatusLS = .gotError(error)
				state.toast = ToastState(mode: .alert,
										 type: .error(.red),
										 title: error.description)
				return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
					.map { _ in AppDetailsAction.dismissToast }
			}
		case .onDownloadCancelReasons(let result):
			switch result {
			case .success(let cancelReasons):
				state.cancelReasonLS = .gotSuccess
                state.cancelReasons = IdentifiedArrayOf(uniqueElements: cancelReasons)
			case .failure(let error):
				state.isCancelActive = false
				state.cancelReasonLS = .gotError(error)
				state.toast = ToastState(mode: .alert,
										 type: .error(.red),
										 title: error.description)
				return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
					.map { _ in AppDetailsAction.dismissToast }
            }
        case .onResponseChangeCancelReason(let response):
            switch response {
            case .success(_):
                state.toast = ToastState(mode: .banner(.slide), type: .regular, title: "Appointment successfully canceled.")
            case .failure(let error):
                state.toast = ToastState(mode: .alert, type: .error(.red), title: error.description)
            }
            return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                .map { _ in AppDetailsAction.dismissToast }
		case .onResponseChangeAppointment(let response):
            switch response {
            case .success(_):
                state.toast = ToastState(mode: .banner(.slide), type: .regular, title: "Status successfully updated.")
            case .failure(let error):
                state.toast = ToastState(mode: .alert, type: .error(.red), title: error.description)
            }
            return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                .map { _ in AppDetailsAction.dismissToast }
		case .dismissToast:
			state.toast = nil
			return .cancel(id: ToastTimerId())
		case .choosePathwayTemplate(_):
			break
		case .choosePathway(_):
			break
		case .backFromChooseTemplates:
			state.choosePathwayTemplate = nil
		case .backFromPathwaysList:
			state.isPathwayListActive = false
        case .onResponseRescheduleAppointment(let response):
            state.chooseReschedule.isRescheduleActive = false
            switch response {
            case .failure(let error):
                state.toast = ToastState(mode: .alert,
                                         type: .error(.red),
                                         title: error.description)
            case .success(_):
                state.toast = ToastState(mode: .banner(.slide),
                                         type: .regular,
                                         title: "Appointment successfully rescheduled.")
            }
            
            return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
                .map { _ in AppDetailsAction.dismissToast }
        case .chooseReschedule(let rescheduleAction):
            switch rescheduleAction {
            case .onBackButton:
                state.chooseReschedule.isRescheduleActive = false
            case .onSelectedOkRescheduleCalendar(let date):
                state.app.start_date = date
                return env.clientsAPI.updateAppointment(appointment: AppointmentBuilder(appointment: state.app) )
                    .receive(on: RunLoop.main)
                    .catchToEffect()
                    .map { response in AppDetailsAction.onResponseRescheduleAppointment(response) }
                    .eraseToEffect()
            default:
                break
            }
        }
		return .none
	}
)
