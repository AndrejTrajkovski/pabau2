import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine

public class CalendarWeekViewController: BaseCalendarViewController {
	
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
				if self?.areNotSame(date1: newInitDate, date2: self!.weekView.initDate) ?? false {
					self?.weekView.updateWeekView(to: newInitDate)
				}
			}).store(in: &self.cancellables)
		
		self.viewStore.publisher.appointments.removeDuplicates()
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				let events = $0.mapValues { $0.flatMap { $0 }}
				self?.weekView.forceReload(reloadEvents: events)
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
}

extension CalendarWeekViewController: JZLongPressViewDelegate {
	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
		let endDate = Calendar(identifier: .gregorian).date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
		let newApp = AppointmentEvent(appointment: CalAppointment.dummyInit(start: startDate, end: endDate))
		viewStore.send(.addAppointment(newApp))
	}

	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
		guard let app = editingEvent as? AppointmentEvent else { return }
		var calApp = app.app
		updateTimeOn(&calApp, startDate)
		let newApp = AppointmentEvent(appointment: calApp)
		viewStore.send(.replaceAppointment(newApp: newApp,
										   id: app.app.id))
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
