import Foundation

public struct CalendarState: Equatable {
	public init() {}
	var selectedDate: Date = Calendar.current.startOfDay(for: Date())
}
