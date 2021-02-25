import Foundation
import SwiftUI
import Model
import Util
import ComposableArchitecture

public let appointmentsListReducer: Reducer<AppointmentsListState, AppointmentsListAction, ClientsEnvironment> = Reducer.combine(
	ClientCardChildReducer<[CCAppointment]>().reducer.pullback(
		state: \AppointmentsListState.childState,
		action: /AppointmentsListAction.action,
		environment: { $0 }
	)
)

public enum AppointmentsListAction: ClientCardChildParentAction, Equatable {
	var action: GotClientListAction<[CCAppointment]>? {
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
	case action(GotClientListAction<[CCAppointment]>)
	typealias T = [CCAppointment]
}

public struct AppointmentsListState: ClientCardChildParentState, Equatable {
	typealias T = [CCAppointment]
	var childState: ClientCardChildState<[CCAppointment]>
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
	let app: CCAppointment
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
					Text(app.service).font(.medium17)
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
	let app: CCAppointment
	var body: some View {
		HStack {
			if let date = app.startDate {
				DateLabel(date: date)
			}
			LocationLabel(location: app.locationName ?? "")
		}
	}
}
