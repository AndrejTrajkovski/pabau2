import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents

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
		environment: { $0 })
)

public struct AppDetailsState: Equatable {

	public init(app: CalAppointment) {
		self.app = app
	}

	public var app: CalAppointment
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
