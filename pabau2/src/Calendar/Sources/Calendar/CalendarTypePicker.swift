import SwiftUI
import ComposableArchitecture

public struct CalendarTypePickerState: Equatable {
	var isDropdownShown: Bool
	var appointments: Appointments
	var calendarType: CalendarType
}

public enum CalendarTypePickerAction {
	case onSelect(CalendarType)
	case toggleDropdown
}

public let calTypePickerReducer: Reducer<CalendarTypePickerState, CalendarTypePickerAction, CalendarEnvironment> = .init { state, action, _ in
	switch action {
	case .onSelect(let calType):
		state.calendarType = calType
		state.appointments.switchTo(calType: calType)
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
			CalendarTypeRow(calendarType: viewStore.state.calendarType,
							isSelected: true,
							onTap: { _ in
								viewStore.send(.toggleDropdown)
			}).popover(isPresented: .constant(viewStore.state.isDropdownShown)) {
				ForEach(CalendarType.allCases, id: \.self) { calType in
					CalendarTypeRow(calendarType: calType,
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
	let calendarType: CalendarType
	var isSelected: Bool
	let onTap: (CalendarType) -> Void

	var body: some View {
		HStack {
			Text(self.calendarType.title)
				.bold()
				.padding()
			if self.isSelected {
				Image(systemName: "chevron.down")
					.foregroundColor(.blue)
			}
		}.onTapGesture {
			self.onTap(self.calendarType)
		}
		.frame(height: 48)
	}
}
