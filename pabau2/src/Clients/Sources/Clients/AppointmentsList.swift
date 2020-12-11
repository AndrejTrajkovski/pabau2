import Foundation
import SwiftUI
import Model
import Util
import ComposableArchitecture

public let appointmentsListReducer: Reducer<AppointmentsListState, AppointmentsListAction, ClientsEnvironment> = Reducer.combine(
	ClientCardChildReducer<[Appointment]>().reducer.pullback(
		state: \AppointmentsListState.childState,
		action: /AppointmentsListAction.action,
		environment: { $0 }
	)
)

public enum AppointmentsListAction: ClientCardChildParentAction, Equatable {
	var action: GotClientListAction<[Appointment]>? {
		get {
			if case .action(let app) = self {
				return app
			} else {
				return nil
			}
		}
		set {
			if let newValue = newValue {
				self = .action(newValue)
			}
		}
	}
	case action(GotClientListAction<[Appointment]>)
	typealias T = [Appointment]
}

public struct AppointmentsListState: ClientCardChildParentState, Equatable {
	typealias T = [Appointment]
	var childState: ClientCardChildState<[Appointment]>
}

struct AppointmentsList: ClientCardChild {
	var store: Store<AppointmentsListState, AppointmentsListAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			List {
				ForEach(viewStore.state.childState.state.indices, id: \.self) { idx in
					AppointmentRow(app: viewStore.state.childState.state[idx])
				}
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
									 initials: app.employeeInitials ?? "",
									 font: .regular18,
									 bgColor: .accentColor)
					.frame(width: 55, height: 55)
					.padding()
				VStack(alignment: .leading) {
					Text(app.service?.name ?? "").font(.medium17)
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
			DateLabel(date: app.start_time)
			LocationLabel(location: app.locationName ?? "")
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
