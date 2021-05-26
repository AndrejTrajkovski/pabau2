import SwiftUI
import ComposableArchitecture
import Appointments

public struct CalendarTypePickerState: Equatable {
	var isCalendarTypeDropdownShown: Bool
	var appointments: Appointments
}

public enum CalendarTypePickerAction {
	case onSelect(Appointments.CalendarType)
	case toggleDropdown
}

public let calTypePickerReducer: Reducer<CalendarTypePickerState, CalendarTypePickerAction, CalendarEnvironment> = .init { state, action, _ in
	switch action {
	case .onSelect(let calTypeId):
		state.isCalendarTypeDropdownShown = false
	case .toggleDropdown:
		state.isCalendarTypeDropdownShown.toggle()
	}
	return .none
}

struct CalendarTypePicker: View {
	let store: Store<CalendarTypePickerState, CalendarTypePickerAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			DropdownTitle(title: viewStore.state.appointments.calendarType.title(),
									expanded: viewStore.state.isCalendarTypeDropdownShown) {
				viewStore.send(.toggleDropdown)
			}
			.popover(isPresented:
						viewStore.binding(
							get: { $0.isCalendarTypeDropdownShown },
							send: CalendarTypePickerAction.toggleDropdown)
			) {
				ForEach(Appointments.CalendarType.allCases, id: \.self) { calType in
					DropdownRow(title: calType.title()).onTapGesture {
						viewStore.send(.onSelect(calType))
					}
					Divider()
				}.background(Color(hex: "F9F9F9"))
			}
		}
	}
}
