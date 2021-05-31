import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents

public let appDetailsButtonsReducer: Reducer<AppDetailsButtonsState, AppDetailsButtonsAction, AppDetailsEnvironment> = .init {
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
		GridItem(.flexible(), spacing: 0)
	]
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 0) {
				ForEach(0..<5) { idx in
					switch idx {
					case 0:
						chooseCancelReason
					case 1:
						chooseStatusButton
					case 2:
						repeatLink
					case 3:
						reschedule
					case 4:
						pathways
					default:
						EmptyView()
					}
				}
			}
		}
	}
	
	@ViewBuilder
	var chooseCancelReason: SingleChoiceLink<TimeSlotButton, CancelReason, TextAndCheckMarkContainer<CancelReason>> {
		SingleChoiceLink(
			content: {
				TimeSlotButton(
					image: "minus.circle",
					title: Texts.cancel) {
					let action = AppDetailsAction.buttons(.onCancel)
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
	var chooseStatusButton: SingleChoiceLink<TimeSlotButton, AppointmentStatus, TextAndCheckMarkContainer<AppointmentStatus>> {
		SingleChoiceLink(
			content: {
				TimeSlotButton(
					image: "pencil.and.ellipsis.rectangle",
					title: Texts.status) {
					let action = AppDetailsAction.buttons(AppDetailsButtonsAction.onStatus)
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
	
	@ViewBuilder
	var reschedule: some View {
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
				image: "arrowshape.turn.up.right",
				title: Texts.reschedule) {
				let action = AppDetailsAction.buttons(AppDetailsButtonsAction.onReschedule)
				self.viewStore.send(action)
			}
		}
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
				image: "arrow.2.circlepath",
				title: Texts.repeat) {
				let action = AppDetailsAction.buttons(AppDetailsButtonsAction.onRepeat)
				self.viewStore.send(action)
			}
		}
	}
	
	@ViewBuilder
	var pathways: some View {
		NavigationLink(
			destination: EmptyView(),
			isActive: .constant(false)
		) {
			TimeSlotButton(
				image: "list.bullet.rectangle",
				title: Texts.startPathway) {
				let action = AppDetailsAction.buttons(AppDetailsButtonsAction.onStartPathway)
				self.viewStore.send(action)
			}
		}
	}
}
