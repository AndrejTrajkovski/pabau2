import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents
import CoreDataModel
import Foundation
import ToastAlert
import ToastUI
import Combine

public typealias CalendarEnvironment = (journeyAPI: JourneyAPI, clientsAPI: ClientsAPI, userDefaults: UserDefaultsConfig, repository: Repository)

public let appDetailsReducer: Reducer<AppDetailsState, AppDetailsAction, CalendarEnvironment> = .combine(
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
//    toastReducer.pullback(
//        state: \AppDetailsState.toastState,
//        action: /AppDetailsAction.onDisplayToast,
//        environment: { _ in ToastEnvironment() } ),
    
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
                
            default:
                break
            }
            break
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
				state.appStatuses = IdentifiedArray(downloadStatuses)
			case .failure(let error):
				break
			}
		case .cancelReasonsResponse(let result):
			switch result {
			case .success(let cancelReasons):
				state.cancelReasons = IdentifiedArray(cancelReasons)
			case .failure(let error):
				break
			}
		case .onResponseChangeAppointment:
			break
		case .toast(_):
			break
		}
        return .none
    }
)

public struct AppDetailsState: Equatable {

    public init(app: Appointment) {
        self.app = app
    }

    public var app: Appointment
    var isPaymentActive: Bool = false
    var isDocumentsActive: Bool = false
    var isRescheduleActive: Bool = false

    var isCancelActive: Bool = false
    var chosenCancelReasonId: CancelReason.ID?
	var cancelReasons: IdentifiedArrayOf<CancelReason> = []
    var isStatusActive: Bool = false
	var appStatuses: IdentifiedArrayOf<AppointmentStatus> = []
    var chooseRepeat: ChooseRepeatState = ChooseRepeatState()
    var toastState: ToastState = ToastState()
	
	var cancelReasonLS: LoadingState = .initial
	var chooseStatusLS: LoadingState = .initial
}

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
    case toast(ToastAction)
}

public struct AppointmentDetails: View {
    public let store: Store<AppDetailsState, AppDetailsAction>
    @ObservedObject var viewStore: ViewStore<AppDetailsState, AppDetailsAction>
    public init(store: Store<AppDetailsState, AppDetailsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            AppDetailsHeader(store: self.store)
            Spacer().frame(height: 32)
            AppDetailsInfo(store: self.store)
            AppDetailsButtons(store: self.store)
                .fixedSize(horizontal: false, vertical: true)
            AddEventPrimaryBtn(title: Texts.addService) {
                self.viewStore.send(.addService)
            }
        }
//        .toast(isPresented: viewStore.binding(get: { $0.toastState.isPresented },
//                                              send: AppDetailsAction.onDisplayToast(ToastAction.onDisplay)),
//               content: {
//                    ToastView("Loading....")
//                                .toastViewStyle(IndefiniteProgressToastViewStyle())
//               })
        .addEventWrapper(
            onXBtnTap: { self.viewStore.send(.close) })
    }
}

extension AppDetailsState {
    var chooseCancelReason: SingleChoiceLinkState<CancelReason> {
        get {
            SingleChoiceLinkState<CancelReason>.init(
                dataSource: cancelReasons,
                chosenItemId: chosenCancelReasonId,
				isActive: isCancelActive,
				loadingState: cancelReasonLS)
        }
        set {
            self.cancelReasons = newValue.dataSource
            self.chosenCancelReasonId = newValue.chosenItemId
            self.isCancelActive = newValue.isActive
			self.cancelReasonLS = newValue.loadingState
        }
    }

    var chooseStatus: SingleChoiceLinkState<AppointmentStatus> {
        get {
            SingleChoiceLinkState<AppointmentStatus>(
                dataSource: appStatuses,
                chosenItemId: app.status?.id,
				isActive: isStatusActive,
				loadingState: chooseStatusLS)
        }
        set {
            self.appStatuses = newValue.dataSource
            self.app.status = newValue.chosenItemId.flatMap { appStatuses[id: $0] }
            self.isStatusActive = newValue.isActive
			self.chooseStatusLS = newValue.loadingState
        }
    }

    var itemsState: AppDetailsButtonsState {
        get {
            AppDetailsButtonsState(
                isPaymentActive: isPaymentActive,
                isCancelActive: isCancelActive,
                isStatusActive: isStatusActive,
                isRepeatActive: chooseRepeat.isRepeatActive,
                isDocumentsActive: isDocumentsActive,
                isRescheduleActive: isRescheduleActive)
        }
        set {
            self.isPaymentActive = newValue.isPaymentActive
            self.isCancelActive = newValue.isCancelActive
            self.isStatusActive = newValue.isStatusActive
            self.chooseRepeat.isRepeatActive = newValue.isRepeatActive
            self.isDocumentsActive = newValue.isDocumentsActive
            self.isRescheduleActive = newValue.isRescheduleActive
        }
    }

}
extension AppointmentStatus: SingleChoiceElement { }
extension CancelReason: SingleChoiceElement {}
