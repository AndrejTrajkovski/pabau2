import SwiftUI
import ComposableArchitecture

public struct CalendarTypePickerState: Equatable {
	var isDropdownShown: Bool
	var appointments: Appointments
}

public enum CalendarTypePickerAction {
	case onSelect(Appointments.CalendarType)
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
			CalendarTypeRow(calType: viewStore.state.appointments.calendarType,
							isSelected: true,
							onTap: { _ in
								viewStore.send(.toggleDropdown)
							}).popover(isPresented: .constant(viewStore.state.isDropdownShown)) {
								ForEach(Appointments.CalendarType.allCases, id: \.self) { calType in
									CalendarTypeRow(calType: calType,
													isSelected: false,
													onTap: {
														viewStore.send(.onSelect($0))
													})
									Divider()
								}.background(Color(hex: "F9F9F9"))
							}
		}
	}
}

struct CalendarTypeRow: View {
	let calType: Appointments.CalendarType
	var isSelected: Bool
	let onTap: (Appointments.CalendarType) -> Void

	var body: some View {
		HStack {
			Text(calType.title())
				.bold()
				.padding()
			if self.isSelected {
				Image(systemName: "chevron.down")
					.foregroundColor(.blue)
			}
		}.onTapGesture {
			self.onTap(self.calType)
		}
		.frame(height: 48)
	}
}
