import Model
import ComposableArchitecture
import SwiftUI
import SharedComponents
import Util
import ChooseEmployees
import ChooseLocation

struct ServicesDurationSection: View {
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		VStack {
			HStack(spacing: 24.0) {
				TitleAndValueLabel(
					"SERVICE",
					self.viewStore.state.services.chosenService?.name ?? "Choose Service",
					self.viewStore.state.services.chosenService?.name == nil ? Color.grayPlaceholder : nil,
					viewStore.binding(
						get: { $0.chooseServiceConfigurator },
						send: .ignore
					)
				).onTapGesture {
					self.viewStore.send(.didTapServices)
				}
				NavigationLink.emptyHidden(
					self.viewStore.state.services.isChooseServiceActive,
					ChooseService(store: self.store.scope(state: { $0.services }, action: {
						.services($0)
					}))
				)
				SingleChoiceLink.init(
					content: {
						TitleAndValueLabel.init(
							"DURATION", self.viewStore.state.durations.chosenItemName ?? "")
					},
					store: self.store.scope(
						state: { $0.durations },
						action: { .durations($0) }
					),
					cell: TextAndCheckMarkContainer.init(state:),
					title: "Duration"
				)
			}
			HStack(spacing: 24.0) {
				TitleAndValueLabel(
					"WITH",
					self.viewStore.state.with.chosenEmployee?.name ?? "Choose Employee",
					self.viewStore.state.with.chosenEmployee?.name == nil ? Color.grayPlaceholder : nil,
					viewStore.binding(
						get: { $0.employeeConfigurator },
						send: .ignore
					)
				).onTapGesture {
					self.viewStore.send(.didTapWith)
				}
				NavigationLink.emptyHidden(
					self.viewStore.state.with.isChooseEmployeesActive,
					ChooseEmployeesView(
						store: self.store.scope(
							state: { $0.with },
							action: { .with($0) }
						)
					)
				)
				TitleAndValueLabel(
					"LOCATION",
					self.viewStore.state.chooseLocationState.chosenLocation?.name ?? "Choose Location",
					self.viewStore.state.chooseLocationState.chosenLocation?.name == nil ? Color.grayPlaceholder : nil
				).onTapGesture {
					self.viewStore.send(.onChooseLocation)
				}
				NavigationLink.emptyHidden(
					self.viewStore.state.chooseLocationState.isChooseLocationActive,
					ChooseLocationView(
						store: self.store.scope(
							state: { $0.chooseLocationState },
							action: { .chooseLocation($0) }
						)
					)
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
		}.wrapAsSection(title: "Services")
	}
}

