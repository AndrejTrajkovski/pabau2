import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine

public class CalendarWeekViewController: BaseCalendarViewController {
	
	let viewStore: ViewStore<CalendarState, CalendarWeekViewAction>

	init(_ viewStore: ViewStore<CalendarState, CalendarWeekViewAction>) {
		self.viewStore = viewStore
		super.init()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		weekView.setupCalendar(numOfDays: 7,
							   setDate: viewStore.state.selectedDate.getMondayOfWeek(),
							   allEvents: [:],
							   scrollType: .pageScroll,
							   firstDayOfWeek: .Monday,
							   scrollableRange: (nil, nil))
		self.viewStore.publisher.selectedDate.removeDuplicates()
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				let newInitDate = $0.getMondayOfWeek()
				self?.weekView.updateWeekView(to: newInitDate)
			}).store(in: &self.cancellables)
	}

	public override func loadView() {
		let calendarView = CalendarWeekView.init(frame: .zero)
		calendarView.baseDelegate = self
		calendarView.longPressDataSource = self
		calendarView.longPressDelegate = self
		calendarView.longPressTypes = [.addNew, .move]
		calendarView.addNewDurationMins = 60
		calendarView.moveTimeMinInterval = 15
		view = calendarView
	}
	
	var weekView: CalendarWeekView {
		self.view as! CalendarWeekView
	}
	
	public override func userDidFlipPage(_ weekView: JZBaseWeekView, isNextPage: Bool) {
		viewStore.send(.onPageSwipe(isNext: isNextPage))
	}
}

extension CalendarWeekViewController: JZLongPressViewDelegate {
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndChangeDurationLongPressAt startDate: Date, endDate: Date) {
		guard let app = editingEvent as? JZAppointmentEvent else { return }
		var calApp = app.app
		updateStartTimeOn(&calApp, startDate)
		calApp.end_time = endDate.split().hms
//		let newApp = JZAppointmentEvent(appointment: calApp)
//		viewStore.send(.replaceAppointment(newApp: newApp,
//										   id: app.app.id))
	}
	
	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
		let endDate = Calendar(identifier: .gregorian).date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
//		let newApp = JZAppointmentEvent(appointment: CalAppointment.dummyInit(start: startDate, end: endDate))
//		viewStore.send(.addAppointment(newApp))
	}

	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
		guard let app = editingEvent as? JZAppointmentEvent else { return }
		var calApp = app.app
		updateStartTimeOn(&calApp, startDate)
//		let newApp = JZAppointmentEvent(appointment: calApp)
//		viewStore.send(.replaceAppointment(newApp: newApp,
//										   id: app.app.id))
	}
}

//if self.isKind(of: CalendarViewController.self) {
//	let dateDisplayed = initDate + (weekView.numOfDays).days //JZCalendar holds previous and next pages in cache, initDate is not the date displayed on screen
//	let date1 = viewStore.state.selectedDate
//	//compare in order not to go in an infinite loop
//	if self.areNotSame(date1: date1,
//					   date2: dateDisplayed) {
//		self.viewStore.send(.datePicker(.selectedDate(dateDisplayed)))
//	}
//} else if self.isKind(of: CalendarWeekViewController.self) {
//	let dateDisplayed = initDate + (weekView.numOfDays).days //JZCalendar holds previous and next pages in cache, initDate is not the date displayed on screen
//	print("dateDisplayed: ", dateDisplayed)
//	let date1 = viewStore.state.selectedDate.getMondayOfWeek()
//	print("date1: ", date1)
//	if self.areNotSame(date1: date1,
//					   date2: dateDisplayed) {
//		let isInPast = dateDisplayed < date1
//		let shiftDate = isInPast ? -1.weeks : 1.weeks
//		let oneWeekDiff = viewStore.state.selectedDate + shiftDate
//		self.viewStore.send(.datePicker(.selectedDate(oneWeekDiff)))
//	}
//}
