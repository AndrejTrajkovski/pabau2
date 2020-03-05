import Foundation
import Combine
import FSCalendar

public class MyCalendarViewModel: ObservableObject {

	@Published var scope: FSCalendarScope
	@Published var date: Date
	var subscriptions = Set<AnyCancellable>()

	public init(_ scope: FSCalendarScope = .week,
							_ date: Date = Date()) {
		self.scope = scope
		self.date = date
	}
}
