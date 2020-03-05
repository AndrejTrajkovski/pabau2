import SwiftUI
import FSCalendarSwiftUI

public struct JourneyView: View {

	let calendarViewModel = MyCalendarViewModel()
	public init () {}
	public var body: some View {
		VStack {
			SwiftUICalendar.init(calendarViewModel)
		}
	}
}
