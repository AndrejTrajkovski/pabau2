import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents

public let appDetailsButtonsReducer: Reducer<AppDetailsButtonsState, AppDetailsButtonsAction, CalendarEnvironment> = .init {
	state, action, env in
	switch action {
	case .onPayment:
		state.isPaymentActive = true
	case .onCancel:
		//state.isCancelActive = true
        break
	case .onStatus:
		//state.isStatusActive = true
        break
    case .onDownloadStatuses:
        state.isStatusActive = true
	case .onRepeat:
		state.isRepeatActive = true
	case .onDocuments:
		state.isDocumentsActive = true
	case .onReschedule:
		state.isRescheduleActive = true
    default:
        break
	}
	return .none
}

public struct AppDetailsButtonsState: Equatable {
	var isPaymentActive: Bool
	var isCancelActive: Bool
	var isStatusActive: Bool
	var isRepeatActive: Bool
	var isDocumentsActive: Bool
	var isRescheduleActive: Bool
}

public enum AppDetailsButtonsAction: Equatable {
	case onPayment
	case onCancel
	case onStatus
	case onRepeat
	case onDocuments
	case onReschedule
	case onStartPathway
    case onDownloadStatuses([AppointmentStatus])
    case onDownloadCancelReasons([CancelReason])
}

struct AppDetailsButtons: View {

    public let store: Store<AppDetailsState, AppDetailsAction>
    @ObservedObject var viewStore: ViewStore<AppDetailsState, AppDetailsAction>

    init(store: Store<AppDetailsState, AppDetailsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

	let columns = [
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
		GridItem(.flexible(), spacing: 0),
	]

	let items = [
		("briefcase", Texts.payment, AppDetailsButtonsAction.onPayment),
		("minus.circle", Texts.cancel, AppDetailsButtonsAction.onCancel),
		("pencil.and.ellipsis.rectangle", Texts.status, AppDetailsButtonsAction.onStatus),
		("arrow.2.circlepath", Texts.repeat, AppDetailsButtonsAction.onRepeat),
		("doc.text", Texts.documents, AppDetailsButtonsAction.onDocuments),
		("arrowshape.turn.up.right", Texts.reschedule, AppDetailsButtonsAction.onReschedule),
		("list.bullet.rectangle", Texts.startPathway, AppDetailsButtonsAction.onStartPathway)
	]

	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 0) {
				ForEach(items.indices) { idx in
					ViewBuilder.buildBlock((idx == 2 || idx == 1 || idx == 3) ?
											ViewBuilder.buildEither(second: choose21or3(idx: idx))
											:
											ViewBuilder.buildEither(first: timeSlot(idx: idx))
					)
				}
			}
		}
	}

	@ViewBuilder
	func choose21or3(idx: Int) -> some View {
		ViewBuilder.buildBlock((idx == 2 || idx == 1) ?
								ViewBuilder.buildEither(second: chooseStatusOrCancelReason(idx: idx))
								:
								ViewBuilder.buildEither(first: repeatLink)
		)
	}

	@ViewBuilder
	func chooseStatusOrCancelReason(idx: Int) -> some View {
		ViewBuilder.buildBlock((idx == 2) ?
								ViewBuilder.buildEither(second: chooseStatusButton)
								:
								ViewBuilder.buildEither(first: chooseCancelReason)
		)
	}

	func timeSlot(idx: Int) -> TimeSlotButton {
		return TimeSlotButton(
			image: items[idx].0,
			title: items[idx].1) {
			let action = AppDetailsAction.buttons(items[idx].2)
			self.viewStore.send(action)
		}
	}

	var chooseStatusButton: SingleChoiceLink<TimeSlotButton, AppointmentStatus, TextAndCheckMarkContainer<AppointmentStatus>> {
		SingleChoiceLink(
			content: {
				TimeSlotButton(
					image: items[2].0,
					title: items[2].1) {
					let action = AppDetailsAction.buttons(items[2].2)
					self.viewStore.send(action)
				}
			},
			store: self.store.scope(
				state: { $0.chooseStatus },
				action: { .chooseStatus($0) }
			),
			cell: TextAndCheckMarkContainer.init(state:)
		)
	}

	var chooseCancelReason: SingleChoiceLink<TimeSlotButton, CancelReason, TextAndCheckMarkContainer<CancelReason>> {
		SingleChoiceLink(
			content: {
				TimeSlotButton(
					image: items[1].0,
					title: items[1].1) {
					let action = AppDetailsAction.buttons(items[1].2)
					self.viewStore.send(action)
				}
			},
			store: self.store.scope(
				state: { $0.chooseCancelReason },
				action: { .chooseCancelReason($0) }
			),
			cell: TextAndCheckMarkContainer.init(state:)
		)
	}

	@ViewBuilder
	var repeatLink: some View {
		NavigationLink(
			destination: IfLetStore(store.scope(state: { $0.chooseRepeat },
												action: { .chooseRepeat($0) }),
									then: ChooseRepeat.init(store:)
			),
			isActive: viewStore.binding(
				get: \.chooseRepeat.isRepeatActive,
				send: { $0 ? AppDetailsAction.buttons(.onRepeat) : AppDetailsAction.chooseRepeat(.onBackBtn) }
			)
		) {
			TimeSlotButton(
				image: items[3].0,
				title: items[3].1) {
				let action = AppDetailsAction.buttons(items[3].2)
				self.viewStore.send(action)
			}
		}
	}
}
