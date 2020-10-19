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
		
	}
	
	public func userDidFlipPage(_ weekView: JZBaseWeekView, isNextPage: Bool) {
		viewStore.send(.userDidSwipePageTo(isNext: isNextPage))
	}

	public func areNotSame(date1: Date, date2: Date) -> Bool {
		return date1.compare(toDate: date2, granularity: .day) != .orderedSame
	}
}

extension BaseCalendarViewController {
	public func updateStartTimeOn(_ calEvent: inout CalAppointment, _ startDate: Date) {
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
