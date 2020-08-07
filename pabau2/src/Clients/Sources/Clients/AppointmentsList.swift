import Foundation
import SwiftUI
import Model
import Util

//let appointmentReducer = Reducer<ClientCardChildState<[Appointment]>, GotClientListAction<[Appointment]>, ClientsEnvironment> { state, action, env in
//	return .none
//}

struct AppointmentsList: ClientCardChild {
	var state: [Appointment]
	var body: some View {
		List {
			ForEach(state.indices, id: \.self) { idx in
				AppointmentRow(app: self.state[idx])
			}
		}
	}
}

struct AppointmentRow: View {
	let app: Appointment
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				AvatarView(avatarUrl: nil,
									 initials: app.employeeInitials,
									 font: .regular18,
									 bgColor: .accentColor)
					.frame(width: 55, height: 55)
					.padding()
				VStack(alignment: .leading) {
					Text(app.service.name).font(.medium17)
					DateLocation(app: app)
				}
				Spacer()
				AppointmentIcons()
					.padding()
			}
			Divider()
		}
	}
}

struct AppointmentIcons: View {
	var body: some View {
		HStack {
			Image(systemName: "magnifyingglass.circle")
			Image(systemName: "arrow.clockwise.circle")
			Image(systemName: "envelope.circle")
			Image(systemName: "xmark.circle")
		}
		.font(.regular36)
		.foregroundColor(.accentColor)
	}
}

struct LocationLabel: View {
	let location: String
	var body: some View {
		HStack {
			Image(systemName: "location")
				.foregroundColor(.accentColor)
			Text(location)
				.font(.regular15)
				.foregroundColor(.clientCardNeutral)
		}
	}
}

struct DateLocation: View {
	let app: Appointment
	var body: some View {
		HStack {
			DateLabel(date: app.from)
			LocationLabel(location: app.locationName)
		}
	}
}

struct AppointmentRow_Previews: PreviewProvider {
	static var previews: some View {
		AppointmentRow(app: Appointment(id: 1,
																		from: Date(),
																		to: Date(),
																		employeeId: 1,
																		employeeInitials: "AT", locationId: 1, locationName: "London", service: BaseService.init(id: 1, name: "Botox", color: "#eb4034")))
	}
}
