import Model
import ComposableArchitecture
import SwiftUI
import SharedComponents
import Util

struct ClientDaySection: View {
	let store: Store<AddAppointmentState, AddAppointmentAction>
	@ObservedObject var viewStore: ViewStore<AddAppointmentState, AddAppointmentAction>
	init (store: Store<AddAppointmentState, AddAppointmentAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	var body: some View {
		Group {
            DeviceHVStack {
				TitleAndValueLabel(
					"CLIENT",
					self.viewStore.state.clients.chosenClient?.fullname ??  "Choose client",
					self.viewStore.state.clients.chosenClient?.fullname == nil ? Color.grayPlaceholder : nil,
					.constant(viewStore.chooseClintValidator)
				).onTapGesture {
					self.viewStore.send(.didTabClients)
				}
				DatePickerControl.init(
					"DAY", viewStore.binding(
						get: { $0.startDate },
						send: { .chooseStartDate($0!) }
					), .constant(nil)
				).isHidden(!viewStore.isAllDay, remove: true)
				DatePickerControl.init(
					"DAY", viewStore.binding(
						get: { $0.startDate },
						send: { .chooseStartDate($0!) }
					),
					.constant(nil),
					mode: .dateAndTime
				).isHidden(viewStore.isAllDay, remove: true)
			}
			NavigationLink.emptyHidden(
				self.viewStore.state.clients.isChooseClientsActive,
				ChooseClients(
					store: self.store.scope(
						state: { $0.clients },
						action: {.clients($0) }
					)
				)
			)
		}
	}
}
