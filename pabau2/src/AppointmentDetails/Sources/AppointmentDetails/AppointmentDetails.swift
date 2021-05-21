import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents
import CoreDataModel
import Foundation

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
                return env.clientsAPI.getAppointmentStatus()
                    .catchToEffect()
                    .map{ response in
                        switch response {
                        case .success(let statuses):
                            return AppDetailsAction.buttons(.onDownloadStatuses(statuses))
                        case .failure(let error):
                            return AppDetailsAction.buttons(.onDownloadStatuses([]))
                        }
                    }
                    .eraseToEffect()
            case .onCancel:
                return env.clientsAPI.getAppointmentCancelReasons()
                    .catchToEffect()
                    .map { response in
                        switch response {
                        case .success(let reasons):
                            return AppDetailsAction.buttons(.onDownloadCancelReasons(reasons))
                        case .failure(let error):
                            return AppDetailsAction.buttons(.onDownloadCancelReasons([]))
                        }
                    }
                    .eraseToEffect()
                
            case .onDownloadStatuses(let statuses):
                state.appStatuses = IdentifiedArrayOf(statuses)
                state.isStatusActive = true
            case .onDownloadCancelReasons(let reasons):
                state.cancelReasons = IdentifiedArrayOf(reasons)
                state.isCancelActive = true
            default:
                break
            }
            break
            
        default:
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
    var cancelReasons = IdentifiedArrayOf(CancelReason.mock)
    var isStatusActive: Bool = false
    var appStatuses = IdentifiedArrayOf(AppointmentStatus.mock)
    var chooseRepeat: ChooseRepeatState = ChooseRepeatState()
}

public enum AppDetailsAction {
    case buttons(AppDetailsButtonsAction)
    case chooseStatus(SingleChoiceLinkAction<AppointmentStatus>)
    case chooseCancelReason(SingleChoiceLinkAction<CancelReason>)
    case addService
    case chooseRepeat(ChooseRepeatAction)
    case close
    case onResponseChangeAppointment
    case onResponseCreateReccuringAppointment
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
        }.addEventWrapper(
            onXBtnTap: { self.viewStore.send(.close) })
    }
}

extension AppDetailsState {
    var chooseCancelReason: SingleChoiceLinkState<CancelReason> {
        get {
            SingleChoiceLinkState<CancelReason>.init(
                dataSource: cancelReasons,
                chosenItemId: chosenCancelReasonId,
                isActive: isCancelActive)
        }
        set {
            self.cancelReasons = newValue.dataSource
            self.chosenCancelReasonId = newValue.chosenItemId
            self.isCancelActive = newValue.isActive
        }
    }

    var chooseStatus: SingleChoiceLinkState<AppointmentStatus> {
        get {
            SingleChoiceLinkState<AppointmentStatus>(
                dataSource: appStatuses,
                chosenItemId: app.status?.id,
                isActive: isStatusActive)
        }
        set {
            self.appStatuses = newValue.dataSource
            self.app.status = newValue.chosenItemId.flatMap { appStatuses[id: $0] }
            self.isStatusActive = newValue.isActive
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
