import SwiftUI
import FSCalendar
import ComposableArchitecture
import SwiftDate
import Model

public struct CalendarDatePicker: View {
	let store: Store<Date, CalendarDatePickerAction>
	let isWeekView: Bool
	let scope: FSCalendarScope

	@State var totalHeight: CGFloat?
	public var body: some View {
		WithViewStore(store) { viewStore in
			SwiftUICalendar.init(viewStore.state,
								 scope,
								 isWeekView: isWeekView,
								 onHeightChange: { height in
									DispatchQueue.main.async {
										withAnimation {
											self.totalHeight = height
										}
									}
								 },
								 onDateChanged: { viewStore.send(.selectedDate($0))}
			).frame(height: self.totalHeight)
		}
	}

	public init(store: Store<Date, CalendarDatePickerAction>,
				isWeekView: Bool,
				scope: FSCalendarScope) {
		self.store = store
		self.isWeekView = isWeekView
		self.scope = scope
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
	private let isWeekView: Bool
	let onHeightChange: (CGFloat) -> Void
	private var onDateChanged: (Date) -> Void

	public init(_ date: Date,
				_ scope: FSCalendarScope,
				isWeekView: Bool,
				onHeightChange: @escaping (CGFloat) -> Void,
				onDateChanged: @escaping (Date) -> Void) {
		self.date = date
		self.scope = scope
		self.isWeekView = isWeekView
		self.onHeightChange = onHeightChange
		self.onDateChanged = onDateChanged
	}

	public func makeUIView(context: UIViewRepresentableContext<SwiftUICalendar>) -> FSCalendar {
		print("makeUIView FSCalendar")
		let calendar = FSCalendar()
		calendar.firstWeekday = 2 //Monday
		update(calendar: calendar, selDate: date, isWeekView: isWeekView)
		calendar.delegate = context.coordinator
		return calendar
	}

	public func updateUIView(_ calendar: FSCalendar, context: UIViewRepresentableContext<SwiftUICalendar>) {
		update(calendar: calendar, selDate: date, isWeekView: isWeekView)
		calendar.setScope(scope, animated: true)
	}

	func update(calendar: FSCalendar,
				selDate: Date,
				isWeekView: Bool) {
		let newDates = datesToSelect(date: selDate, isWeekView: isWeekView)
		if calendar.selectedDates != newDates {
			calendar.selectedDates.forEach {
				calendar.deselect($0)
			}
			newDates.forEach {
				calendar.select($0)
			}
		}

		if isWeekView {
			calendar.setCurrentPage(selDate, animated: true)
			calendar.allowsMultipleSelection = true
		} else {
			calendar.allowsMultipleSelection = false
		}
	}

	func datesToSelect(date: Date,
					   isWeekView: Bool) -> [Date] {
		if isWeekView {
			return date.datesInWeekOf()
		} else {
			return [date]
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
		let firstDayOfWeek = self.getMondayOfWeek()
		let shiftedWeekDaysIdxs = Array(0...6)
			.map { firstDayOfWeek + $0.days }
		return shiftedWeekDaysIdxs
	}

	public func getMondayOfWeek() -> Date {
		self.nextWeekday(.monday) - 1.weeks
	}
}
