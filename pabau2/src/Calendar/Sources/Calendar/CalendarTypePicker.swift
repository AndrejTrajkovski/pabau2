import SwiftUI
import ComposableArchitecture
import Appointments

public struct CalendarTypePickerState: Equatable {
	var isDropdownShown: Bool
	var appointments: CalAppointments
}

public enum CalendarTypePickerAction {
	case onSelect(CalAppointments.CalendarType)
	case toggleDropdown
}

public let calTypePickerReducer: Reducer<CalendarTypePickerState, CalendarTypePickerAction, CalendarEnvironment> = .init { state, action, _ in
	switch action {
	case .onSelect(let calTypeId):
//		state.calendarType = calType
		state.isDropdownShown = false
	case .toggleDropdown:
		state.isDropdownShown.toggle()
	}
	return .none
}

struct CalendarTypePicker: View {
	let store: Store<CalendarTypePickerState, CalendarTypePickerAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			CalendarTypePickerTitle(calType: viewStore.state.appointments.calendarType,
									expanded: viewStore.state.isDropdownShown) {
				viewStore.send(.toggleDropdown)
			}
			.popover(isPresented: .constant(viewStore.state.isDropdownShown)) {
				ForEach(CalAppointments.CalendarType.allCases, id: \.self) { calType in
					CalendarTypeRow(calType: calType).onTapGesture {
						viewStore.send(.onSelect(calType))
					}
					Divider()
				}.background(Color(hex: "F9F9F9"))
			}
		}
	}
}

struct CalendarTypePickerTitle: View {
	let calType: CalAppointments.CalendarType
	let expanded: Bool
	let action: () -> Void
	var body: some View {
		Button(action: action) {
			HStack {
				CalendarTypeRow(calType: calType)
					.foregroundColor(.black)
				Image(systemName: expanded ? "chevron.down" : "chevron.up")
					.foregroundColor(.blue)
			}
		}
	}
}

struct CalendarTypeRow: View {
	let calType: CalAppointments.CalendarType

	var body: some View {
		Text(calType.title())
			.bold()
			.padding()
			.frame(height: 48)
	}
}
