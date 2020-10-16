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
	let onHeightChange: (CGFloat) -> Void
	private var onDateChanged: (Date) -> Void
	
	public init(_ date: Date,
				_ scope: FSCalendarScope,
				onHeightChange: @escaping (CGFloat) -> Void,
				onDateChanged: @escaping (Date) -> Void) {
		self.scope = scope
		self.date = date
		self.onHeightChange = onHeightChange
		self.onDateChanged = onDateChanged
	}

	public func makeUIView(context: UIViewRepresentableContext<SwiftUICalendar>) -> FSCalendar {
		print("makeUIView FSCalendar")
		let calendar = FSCalendar()
		calendar.select(date)
		calendar.delegate = context.coordinator
		return calendar
	}

	public func updateUIView(_ uiView: FSCalendar, context: UIViewRepresentableContext<SwiftUICalendar>) {
		uiView.select(uiView.selectedDate)
		uiView.setScope(scope, animated: false)
	}
	
	func update(calendar: FSCalendar,
				selDate: Date,
				isWeekView: Bool) {
		if isWeekView {
			calendar.allowsMultipleSelection = true
			selDate.datesInWeekOf().forEach {
				calendar.select($0)
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
	}
}

extension Date {
	
	func datesInWeekOf() -> [Date] {
		//FIXME: refactor this bs
		let gregorian = Calendar(identifier: .gregorian)
		var compsToGet = Set<Calendar.Component>.init()
		compsToGet.insert(.weekOfYear)
		let dateComps = gregorian.dateComponents(compsToGet, from: self)
		var weekStart = gregorian.date(from: dateComps)
		var moveWeeks = DateComponents()
		moveWeeks.weekOfYear = 0
		weekStart = gregorian.date(byAdding: moveWeeks, to: weekStart!)
		let days = Array(0...6).map {
			return gregorian.date(byAdding: $0.days, to: weekStart!)!
		}
		return days
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
