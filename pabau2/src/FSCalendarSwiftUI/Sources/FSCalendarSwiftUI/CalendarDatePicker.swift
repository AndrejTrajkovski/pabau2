import SwiftUI
import FSCalendar
import ComposableArchitecture
import SwiftDate

public struct CalendarDatePicker: View {
	let store: Store<Date, CalendarDatePickerAction>
	@State var totalHeight: CGFloat?
	public var body: some View {
		WithViewStore(store) { viewStore in
			SwiftUICalendar.init(viewStore.state,
								 .week,
								 isWeek: true,
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

struct SwiftUICalendar: UIViewRepresentable {
	public typealias UIViewType = FSCalendar
	private let scope: FSCalendarScope
	private let date: Date
	private let isWeek: Bool
	let onHeightChange: (CGFloat) -> Void
	private var onDateChanged: (Date) -> Void

	public init(_ date: Date,
				_ scope: FSCalendarScope,
				isWeek: Bool,
				onHeightChange: @escaping (CGFloat) -> Void,
				onDateChanged: @escaping (Date) -> Void) {
		self.date = date
		self.scope = scope
		self.isWeek = isWeek
		self.onHeightChange = onHeightChange
		self.onDateChanged = onDateChanged
	}

	public func makeUIView(context: UIViewRepresentableContext<SwiftUICalendar>) -> FSCalendar {
		print("makeUIView FSCalendar")
		let calendar = FSCalendar()
		calendar.firstWeekday = 2
		update(calendar: calendar, selDate: date, isWeekView: isWeek)
		calendar.delegate = context.coordinator
		return calendar
	}

	public func updateUIView(_ calendar: FSCalendar, context: UIViewRepresentableContext<SwiftUICalendar>) {
		update(calendar: calendar, selDate: date, isWeekView: isWeek)
		calendar.setScope(scope, animated: false)
	}

	func update(calendar: FSCalendar,
				selDate: Date,
				isWeekView: Bool) {
		calendar.selectedDates.forEach {
			calendar.deselect($0)
		}
		if isWeekView {
			print("updateUIView: selDate: ", selDate)
//			let dateIntervalWeek = Calendar(identifier: .gregorian).dateInterval(of: .weekOfYear, for: selDate)
//			dateIntervalWeek?.start
//			print("dateIntervalWeek: ", dateIntervalWeek)
			calendar.setCurrentPage(selDate, animated: true)
			calendar.allowsMultipleSelection = true
			selDate.datesInWeekOf().forEach {
				calendar.select($0)
				print("select date ", $0)
			}
		} else {
			calendar.allowsMultipleSelection = false
			calendar.select(selDate)
		}
	}

	public func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	public class Coordinator: NSObject, FSCalendarDelegate {
		var parent: SwiftUICalendar

		init(_ parent: SwiftUICalendar) {
			self.parent = parent
		}

		public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
			self.parent.onDateChanged(date)
		}

		public func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
			self.parent.onHeightChange(bounds.size.height)
		}
		
		public func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
			return false
		}
	}
}

extension Date {
	// mon // tue // wed // thu // fri // sat // sun
//		12	  13     14  	15	   16      17     18
//		1      2      3      4      5      6       7
//		-4	  -3	 -2 	-1	    +0      1      2
	func datesInWeekOf() -> [Date] {
		let firstDayOfWeek = self.dateAtStartOf(.weekOfYear) + 1.days
		print("firstDayOfWeek", firstDayOfWeek)
		let shiftedWeekDaysIdxs = Array(0...6)
			.map { firstDayOfWeek + $0.days }
		return shiftedWeekDaysIdxs
	}
//	-(NSArray*)daysInWeek:(int)weekOffset fromDate:(NSDate*)date
// {
//	 //ask for current week
//	 NSDateComponents *comps = [[NSDateComponents alloc] init];
//	 comps=[gregorian components:NSWeekCalendarUnit|NSYearCalendarUnit fromDate:date];
//	 //create date on week start
//	 NSDate* weekstart=[gregorian dateFromComponents:comps];
//
//	 NSDateComponents* moveWeeks=[[NSDateComponents alloc] init];
//	 moveWeeks.weekOfYear=weekOffset;
//	 weekstart=[gregorian dateByAddingComponents:moveWeeks toDate:weekstart options:0];
//
//
//	 //add 7 days
// }

}
