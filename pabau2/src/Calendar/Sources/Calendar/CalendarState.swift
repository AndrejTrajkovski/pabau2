import Foundation

public struct CalendarState: Equatable {
	public init() {}
	var isDropdownShown = false
	var selectedCalType: CalendarType = .employee
	var selectedDate: Date = Calendar.current.startOfDay(for: Date())
}

extension CalendarState {

	var calTypePicker: CalendarTypePickerState {
		get {
			CalendarTypePickerState(isDropdownShown: isDropdownShown,
									selectedCalType: selectedCalType)
		}
		set {
			self.isDropdownShown = newValue.isDropdownShown
			self.selectedCalType = newValue.selectedCalType
		}
	}
}
