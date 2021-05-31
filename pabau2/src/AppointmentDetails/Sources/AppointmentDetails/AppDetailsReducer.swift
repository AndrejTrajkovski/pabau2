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
				.map { _ in AppDetailsAction.onResponseCreateReccuringAppointment }
			
		case .onResponseCreateReccuringAppointment:
			state.chooseRepeat.isRepeatActive = false
		case .chooseCancelReason(let singleChoiceLinkAction):
			switch singleChoiceLinkAction {
			case .singleChoice(let single):
				switch single {
				case .action(let id, let action):
					let cancelReason = state.cancelReasons[id: id]
					return env.clientsAPI.appointmentChangeCancelReason(appointmentId: state.app.id, reason: "\(String(describing: cancelReason))")
						.catchToEffect()
						.map { _ in  AppDetailsAction.onResponseChangeAppointment }
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
					return env.clientsAPI.appointmentChangeStatus(appointmentId: state.app.id, status: "\(String(describing: status))")
						.catchToEffect()
						.map { _ in  AppDetailsAction.onResponseChangeAppointment }
						.eraseToEffect()
					
				}
			default:
				break
			}
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
					.map(AppDetailsAction.cancelReasonsResponse)
					.eraseToEffect()
			case .onRepeat:
				break
			case .onReschedule:
				break
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
		case .chooseRepeat(.onBackBtn):
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
				state.appStatuses = IdentifiedArray(downloadStatuses)
			case .failure(let error):
				state.isStatusActive = false
				state.chooseStatusLS = .gotError(error)
				state.toast = ToastState(mode: .alert,
										 type: .error(.red),
										 title: error.description)
				return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
					.map { _ in AppDetailsAction.dismissToast }
			}
		case .cancelReasonsResponse(let result):
			switch result {
			case .success(let cancelReasons):
				state.cancelReasonLS = .gotSuccess
				state.cancelReasons = IdentifiedArray(cancelReasons)
			case .failure(let error):
				state.isCancelActive = false
				state.cancelReasonLS = .gotError(error)
				state.toast = ToastState(mode: .alert,
										 type: .error(.red),
										 title: error.description)
				return Effect.timer(id: ToastTimerId(), every: 2, on: DispatchQueue.main)
					.map { _ in AppDetailsAction.dismissToast }
			}
		case .onResponseChangeAppointment:
			break
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
		}
		return .none
	}
)
