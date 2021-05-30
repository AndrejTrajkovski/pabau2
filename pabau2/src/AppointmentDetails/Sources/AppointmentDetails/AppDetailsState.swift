import ComposableArchitecture
import Model
import ToastAlert
import Util
import SharedComponents

public struct AppDetailsState: Equatable {

	public init(app: Appointment) {
		self.app = app
	}

	public var app: Appointment
	
	var isPaymentActive: Bool = false
	var isDocumentsActive: Bool = false
	var isRescheduleActive: Bool = false
	var isStatusActive: Bool = false
	var isCancelActive: Bool = false
	
	var chosenCancelReasonId: CancelReason.ID?
	var cancelReasons: IdentifiedArrayOf<CancelReason> = []
	var appStatuses: IdentifiedArrayOf<AppointmentStatus> = []
	var chooseRepeat: ChooseRepeatState = ChooseRepeatState()
	var toast: ToastState<AppDetailsAction>?
	
	var cancelReasonLS: LoadingState = .initial
	var chooseStatusLS: LoadingState = .initial
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
