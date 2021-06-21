import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents
import ChoosePathway
import PathwayList

public let appDetailsButtonsReducer: Reducer<AppDetailsButtonsState, AppDetailsButtonsAction, AppDetailsEnvironment> = .init {
	state, action, _ in
	switch action {
	case .onCancel:
		break
	case .onStatus:
		break
	case .onRepeat:
		//state.isRepeatActive = true
        break
	case .onReschedule:
        break
	case .onPathway:
		break
	}
	return .none
}

public struct AppDetailsButtonsState: Equatable {
	var isCancelActive: Bool
	var isStatusActive: Bool
	var isRepeatActive: Bool
	var isRescheduleActive: Bool
}

public enum AppDetailsButtonsAction: Equatable {
	case onCancel
	case onStatus
	case onRepeat
	case onReschedule
	case onPathway
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
						pathwaysLink
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
			destination: IfLetStore(store.scope(state: { $0.chooseReschedule },
												action: { .chooseReschedule($0) }),
                                    then: ChooseReschedule.init(store: )
			),
			isActive: viewStore.binding(
				get: \.chooseReschedule.isRescheduleActive,
                send: { $0 ? AppDetailsAction.buttons(.onReschedule) : AppDetailsAction.chooseReschedule(.onBackButton) }
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
	var pathwaysLink: some View {
		NavigationLink(
			destination: pathwaysContainer,
			isActive: .constant(viewStore.state.isPathwayListActive || viewStore.state.choosePathwayTemplate != nil)
		) {
			TimeSlotButton(
				image: "list.bullet.rectangle",
				title: viewStore.app.pathways.isEmpty ? Texts.startPathway : Texts.pathways) {
				let action = AppDetailsAction.buttons(AppDetailsButtonsAction.onPathway)
				self.viewStore.send(action)
			}
		}
	}
	
	@ViewBuilder
	var pathwaysContainer: some View {
		if viewStore.state.isPathwayListActive {
			Group {
				pathwaysList
				choosePathwayTemplateLink
			}
		} else if viewStore.state.choosePathwayTemplate != nil {
			choosePathwayTemplate
		} else {
			EmptyView()
		}
	}
	
	@ViewBuilder
	var pathwaysList: some View {
		PathwayList(store: store.scope(state: { $0.app },
									   action: { .choosePathway($0) })
		).customBackButton {
			viewStore.send(.backFromPathwaysList)
		}
	}
	
	@ViewBuilder
	var choosePathwayTemplateLink: some View {
		NavigationLink.emptyHidden(viewStore.state.choosePathwayTemplate != nil,
								   choosePathwayTemplate)
	}
	
	@ViewBuilder
	var choosePathwayTemplate: some View {
		IfLetStore(store.scope(state: { $0.choosePathwayTemplate },
							   action: { .choosePathwayTemplate($0) }),
				   then: {
					ChoosePathway.init(store: $0).customBackButton {
						viewStore.send(.backFromChooseTemplates)
					}
				   }
		)
	}
}
