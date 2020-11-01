import SwiftUI
import ComposableArchitecture

public struct CalendarTypePickerState: Equatable {
	var isDropdownShown: Bool
	var calendarType: CalendarType
}

public enum CalendarTypePickerAction {
	case onSelect(CalendarType.Id)
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
			CalendarTypeRow(id: viewStore.state.calendarType.id,
							isSelected: true,
							onTap: { _ in
								viewStore.send(.toggleDropdown)
							}).popover(isPresented: .constant(viewStore.state.isDropdownShown)) {
								ForEach(CalendarType.allIds, id: \.self) { id in
									CalendarTypeRow(id: id,
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
	let id: CalendarType.Id
	var isSelected: Bool
	let onTap: (CalendarType.Id) -> Void

	var body: some View {
		HStack {
			Text(CalendarType.titleFor(id: id))
				.bold()
				.padding()
			if self.isSelected {
				Image(systemName: "chevron.down")
					.foregroundColor(.blue)
			}
		}.onTapGesture {
			self.onTap(self.id)
		}
		.frame(height: 48)
	}
}
