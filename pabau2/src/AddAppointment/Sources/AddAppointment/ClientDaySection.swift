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
		HStack(spacing: 24.0) {
			TitleAndValueLabel(
				"CLIENT",
				self.viewStore.state.clients.chosenClient?.fullname ??  "Choose client",
				self.viewStore.state.clients.chosenClient?.fullname == nil ? Color.grayPlaceholder : nil,
				viewStore.binding(
					get: { $0.chooseClintConfigurator },
					send: .ignore
				)
			).onTapGesture {
				self.viewStore.send(.didTabClients)
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
			DatePickerControl.init(
				"DAY", viewStore.binding(
					get: { $0.startDate },
					send: { .chooseStartDate($0!) }
				)
			).isHidden(!viewStore.isAllDay, remove: true)

			DatePickerControl.init(
				"DAY", viewStore.binding(
					get: { $0.startDate },
					send: { .chooseStartDate($0!) }
				),
				nil,
				mode: .dateAndTime
			).isHidden(viewStore.isAllDay, remove: true)
		}
	}
}
