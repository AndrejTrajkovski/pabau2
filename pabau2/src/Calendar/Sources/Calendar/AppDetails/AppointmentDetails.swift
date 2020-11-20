import SwiftUI
import Util
import ComposableArchitecture
import Model
import ListPicker

public let appDetailsReducer: Reducer<AppDetailsState, AppDetailsAction, CalendarEnvironment> = .combine(
	appDetailsButtonsReducer.pullback(
		state: \AppDetailsState.itemsState,
		action: /AppDetailsAction.buttons,
		environment: { $0 }
	),
	PickerReducer<AppointmentStatus>().reducer.pullback(
		state: \AppDetailsState.chooseStatus,
		action: /AppDetailsAction.chooseStatus,
		environment: { $0 }),
	PickerReducer<CancelReason>().reducer.pullback(
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
	
	var chooseCancelReason: PickerContainerState<CancelReason> {
		get {
			PickerContainerState<CancelReason>.init(
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
	
	var chooseStatus: PickerContainerState<AppointmentStatus> {
		get {
			PickerContainerState<AppointmentStatus>(
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

public enum AppDetailsAction {
	case buttons(AppDetailsButtonsAction)
	case chooseStatus(PickerContainerAction<AppointmentStatus>)
	case chooseCancelReason(PickerContainerAction<CancelReason>)
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
		NavigationView {
			VStack(spacing: 0) {
				AppDetailsHeader(store: self.store)
				Spacer().frame(height: 32)
				AppDetailsInfo(store: self.store)
				AppDetailsButtons(store: self.store)
					.fixedSize(horizontal: false, vertical: true)
				Spacer().frame(height: 32)
				PrimaryButton(Texts.addService,
							  isDisabled: false,
							  { self.viewStore.send(.addService)})
				Spacer().frame(maxHeight: .infinity)
			}.padding(60)
			.navigationBarItems(leading:
									XButton(onTouch: { self.viewStore.send(.close) })
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

extension AppointmentStatus: ListPickerElement { }
extension CancelReason: ListPickerElement {}
