import SwiftUI
import Util
import ComposableArchitecture
import Model
import ListPicker

public let appDetailsButtonsReducer: Reducer<AppDetailsButtonsState, AppDetailsButtonsAction, Any?> = .init {
	state, action, env in
	switch action {
	case .onPayment:
		state.isPaymentActive = true
	case .onCancel:
		state.isCancelActive = true
	case .onStatus:
		state.isStatusActive = true
	case .onRepeat:
		state.isRepeatActive = true
	case .onDocuments:
		state.isDocumentsActive = true
	case .onReschedule:
		state.isRescheduleActive = true
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

public enum AppDetailsButtonsAction: Equatable, CaseIterable {
	case onPayment
	case onCancel
	case onStatus
	case onRepeat
	case onDocuments
	case onReschedule
}

struct AppDetailsButtons: View {

	public let store: Store<AppDetailsState, AppDetailsAction>
	@ObservedObject var viewStore: ViewStore<AppDetailsState, AppDetailsAction>

	init(store: Store<AppDetailsState, AppDetailsAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	let columns = [
		GridItem(.adaptive(minimum: 200), spacing: 0)
	]
	
	let items = [
		("briefcase", Texts.payment, AppDetailsButtonsAction.onPayment),
		("minus.circle", Texts.cancel, AppDetailsButtonsAction.onCancel),
		("pencil.and.ellipsis.rectangle", Texts.status, AppDetailsButtonsAction.onStatus),
		("arrow.2.circlepath", Texts.repeat, AppDetailsButtonsAction.onRepeat),
		("doc.text", Texts.documents, AppDetailsButtonsAction.onDocuments),
		("arrowshape.turn.up.right", Texts.reschedule, AppDetailsButtonsAction.onReschedule)
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

	func timeSlot(idx: Int) -> TimeSlotsItem {
		return TimeSlotsItem(onTap: {
			let action = AppDetailsAction.buttons(items[idx].2)
			self.viewStore.send(action)
		},
		image: items[idx].0,
		title: items[idx].1)
	}

	var chooseStatusButton: PickerContainerStore<TimeSlotsItem, AppointmentStatus> {
		PickerContainerStore(
			content: {
				TimeSlotsItem(onTap: {
				let action = AppDetailsAction.buttons(items[2].2)
				self.viewStore.send(action)
			},
			image: items[2].0,
			title: items[2].1) },
			store: self.store.scope(
				state: { $0.chooseStatus },
				action: { .chooseStatus($0) }
			)
		)
	}

	var chooseCancelReason: PickerContainerStore<TimeSlotsItem, CancelReason> {
		PickerContainerStore(
			content: {
				TimeSlotsItem(onTap: {
				let action = AppDetailsAction.buttons(items[1].2)
				self.viewStore.send(action)
			},
			image: items[1].0,
			title: items[1].1) },
			store: self.store.scope(
				state: { $0.chooseCancelReason },
				action: { .chooseCancelReason($0) }
			)
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
			TimeSlotsItem(onTap: {
				let action = AppDetailsAction.buttons(items[3].2)
				self.viewStore.send(action)
			},
			image: items[3].0,
			title: items[3].1)
		}
	}
}