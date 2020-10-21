import FSCalendarSwiftUI
import ComposableArchitecture
import SwiftUI

public struct CalendarDatePicker: View {
	let store: Store<Date, CalendarDatePickerAction>
	@State var totalHeight: CGFloat?
	public var body: some View {
		WithViewStore(store) { viewStore in
			SwiftUICalendar.init(viewStore.state,
								 .week,
								 onHeightChange: { self.totalHeight = $0 },
								 onDateChanged: { viewStore.send(.selectedDate($0))}
			).frame(height: self.totalHeight)
		}.debug("CalendarDatePicker")
	}
	
	public init(
		store: Store<Date, CalendarDatePickerAction>) {
		self.store = store
	}
}

public enum CalendarDatePickerAction: Equatable {
	case selectedDate(Date)
}

public let calendarDatePickerReducer: Reducer<Date, CalendarDatePickerAction, Any> = Reducer.init { state, action, _ in
	switch action {
	case .selectedDate(let date):
		//TODO: see comment in JZBaseWeekView
		//- If you want to update this value instead of using [updateWeekView(to date: Date)](), please **make sure the date is startOfDay**.
		state = date
	}
	return .none
}
