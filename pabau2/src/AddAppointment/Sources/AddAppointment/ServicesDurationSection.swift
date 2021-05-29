import Model
import ComposableArchitecture
import SwiftUI
import SharedComponents
import Util
import ChooseLocationAndEmployee

struct ServicesDurationSection: View {
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	var body: some View {
		Group {
			VStack(spacing: 16){
				HStack(spacing: 24.0) {
					TitleAndValueLabel(
						"SERVICE",
						self.viewStore.state.services.chosenService?.name ?? "Choose Service",
						self.viewStore.state.services.chosenService?.name == nil ? Color.grayPlaceholder : nil,
						.constant(viewStore.chooseServiceValidator)
					).onTapGesture {
						self.viewStore.send(.didTapServices)
					}
					SingleChoiceLink.init(
						content: {
							TitleAndValueLabel.init(
								"DURATION",
								self.viewStore.state.durations.chosenItemName ?? "",
								nil,
								.constant(nil)
							)
						},
						store: self.store.scope(
							state: { $0.durations },
							action: { .durations($0) }
						),
						cell: TextAndCheckMarkContainer.init(state:),
						title: "Duration"
					)
				}
				ChooseLocationAndEmployee(store:
											store.scope(state: { $0.chooseLocAndEmp },
														action: { .chooseLocAndEmp($0) })
				)
				HStack {
					PlusTitleView()
						.onTapGesture {
							self.viewStore.send(.didTapParticipants)
						}.isHidden(
							!self.viewStore.state.participants.chosenParticipants.isEmpty,
							remove: true
						)
					TitleMinusView(
						title: "\(self.viewStore.state.participants.chosenParticipants.first?.fullName ?? "")..."
					).onTapGesture {
						self.viewStore.send(.removeChosenParticipant)
					}.isHidden(
						self.viewStore.state.participants.chosenParticipants.isEmpty,
						remove: true
					)
					Spacer()
				}
				
			}.wrapAsSection(title: "Services")
			NavigationLink.emptyHidden(
				self.viewStore.state.services.isChooseServiceActive,
				ChooseService(store: self.store.scope(state: { $0.services }, action: {
					.services($0)
				}))
			)
			NavigationLink.emptyHidden(
				self.viewStore.state.participants.isChooseParticipantActive,
				ChooseParticipantView(
					store: self.store.scope(
						state: { $0.participants },
						action: { .participants($0) }
					)
				)
			)
		}
	}
}

