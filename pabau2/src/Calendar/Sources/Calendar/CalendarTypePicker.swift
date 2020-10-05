import SwiftUI
import ComposableArchitecture

public struct CalendarTypePickerState: Equatable {
	var isDropdownShown: Bool
	var selectedCalType: CalendarType
}

public enum CalendarTypePickerAction {
	case onSelect(CalendarType)
	case toggleDropdown
}

public let calTypePickerReducer: Reducer<CalendarTypePickerState, CalendarTypePickerAction, CalendarEnvironment> = .init { state, action, _ in
	switch action {
	case .onSelect(let calType):
		state.selectedCalType = calType
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
			CalendarTypeRow(calendarType: viewStore.state.selectedCalType,
							isSelected: true,
							onTap: { _ in
								viewStore.send(.toggleDropdown)
			}).popover(isPresented: .constant(viewStore.state.isDropdownShown)) {
				ForEach(CalendarType.allCases.filter { $0 != viewStore.state.selectedCalType
				}, id: \.self) { calType in
					CalendarTypeRow(calendarType: calType,
									isSelected: false,
									onTap: {
										viewStore.send(.onSelect($0))
					})
				}
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
			if self.isSelected {
				Image(systemName: "chevron.down")
			}
		}.onTapGesture {
			self.onTap(self.calendarType)
		}.frame(height: 48)
	}
}

struct CalendarTypeRowContainer<Content: View>: View {
	let calendarType: CalendarType
	let onTap: (CalendarType) -> Void
	let content: () -> Content
	var body: some View {
		content()
			
	}
}
