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
//		calendarView.setupCalendar(numOfDays: 1,
//								   setDate: viewStore.state.selectedDate,
//								   allEvents: [:],
//								   scrollType: .pageScroll,
//								   scrollableRange: (nil, nil))
//		self.viewStore.publisher.selectedDate.removeDuplicates().sink(receiveValue: { [weak self] in
//			self?.calendarView.updateWeekView(to: $0)
//			let events = CalAppointment.makeDummy().map(AppointmentEvent.init(appointment:))
//			let sorted = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
//			self?.weekView.forceReload(reloadEvents: sorted)
//		}).store(in: &self.cancellables)
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
		//		let endDate = Calendar.current.date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
		//		let newApp = CalAppointment.dummyInit(start: startDate, end: endDate)
		//		self.appointments.append(newApp)
		//		self.reloadData()
	}
	
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
		//		guard let app = editingEvent as? AppointmentEvent else { return }
		//		let duration = Calendar.current.dateComponents([.minute], from: app.startDate, to: app.endDate).minute!
		//		let selectedIndex = self.appointments.firstIndex(where: { $0.id.rawValue == Int(app.id) })!
		//		let startTime = startDate.separateHMSandYMD().0!
		//		appointments[selectedIndex].start_time = startTime
		//		appointments[selectedIndex].end_time = Calendar.current.date(byAdding: .minute, value: duration, to: startTime)!
		//		self.reloadData()
	}
}
