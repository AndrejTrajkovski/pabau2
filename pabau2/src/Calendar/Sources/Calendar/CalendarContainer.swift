import SwiftUI
import FSCalendarSwiftUI

struct CalendarContainer: View {
	var body: some View {
		VStack {
			SwiftUICalendar.init(viewStore.state.selectedDate,
													 self.$calendarHeight,
													 .week) { date in
														self.viewStore.send(.journey(.selectedDate(date)))
			}
		}
	}
}
