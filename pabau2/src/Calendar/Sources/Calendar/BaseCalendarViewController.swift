import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine

public class BaseCalendarViewController: UIViewController {

	let viewStore: ViewStore<CalendarState, CalendarAction>
	var cancellables: Set<AnyCancellable> = []
	
	init(_ viewStore: ViewStore<CalendarState, CalendarAction>) {
		self.viewStore = viewStore
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		//fix this line for week view
	}
	
	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		JZWeekViewHelper.viewTransitionHandler(to: size, weekView: view as! JZLongPressWeekView)
	}
}

extension BaseCalendarViewController: JZBaseViewDelegate {
	
//	func newSelectedDateFrom(initDate: Date,
//							 previousSelectedDate: Date,
//							 numberOfDays: Int) -> Date {
//
//	}
	
	public func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
		print("initDateDidChange: ", initDate)
		if self.isKind(of: CalendarViewController.self) {
			let dateDisplayed = initDate + (weekView.numOfDays).days //JZCalendar holds previous and next pages in cache, initDate is not the date displayed on screen
			let date1 = viewStore.state.selectedDate
			//compare in order not to go in an infinite loop
			if self.areNotSame(date1: date1,
							   date2: dateDisplayed) {
				self.viewStore.send(.datePicker(.selectedDate(dateDisplayed)))
			}
		} else if self.isKind(of: CalendarWeekViewController.self) {
			let dateDisplayed = initDate + (weekView.numOfDays).days //JZCalendar holds previous and next pages in cache, initDate is not the date displayed on screen
			print("dateDisplayed: ", dateDisplayed)
			let date1 = viewStore.state.selectedDate.getMondayOfWeek()
			print("date1: ", date1)
			if self.areNotSame(date1: date1,
							   date2: dateDisplayed) {
				let isInPast = dateDisplayed < date1
				let shiftDate = isInPast ? -1.weeks : 1.weeks
				let oneWeekDiff = viewStore.state.selectedDate + shiftDate
				self.viewStore.send(.datePicker(.selectedDate(oneWeekDiff)))
			}
		}
	}

//	func reverse(initDate: Date) -> Date {
//		
//	}
	
	func areNotSame(date1: Date, date2: Date) -> Bool {
		return date1.compare(toDate: date2, granularity: .day) != .orderedSame
	}
}

extension BaseCalendarViewController {
	public func updateTimeOn(_ calEvent: inout CalAppointment, _ startDate: Date) {
		let duration = Calendar(identifier: .gregorian).dateComponents([.minute], from: calEvent.start_time, to: calEvent.end_time).minute!
		let splitNewDate = startDate.split()
		calEvent.start_date = splitNewDate.ymd
		calEvent.start_time = splitNewDate.hms
		calEvent.end_time = Calendar(identifier: .gregorian).date(byAdding: .minute, value: duration, to: splitNewDate.hms)!
	}
}

extension BaseCalendarViewController: JZLongPressViewDataSource {
	public func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
		let cell = BaseCalendarCell(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
		cell.layoutSubviews()
		cell.title.text = "New Appointment"
		cell.contentView.backgroundColor = UIColor(hex: 0xEEF7FF)
		cell.colorBlock.backgroundColor = UIColor(hex: 0x0899FF)
		return cell
	}
}
