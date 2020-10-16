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
							   setDate: viewStore.state.selectedDate,
							   allEvents: [:],
							   scrollType: .pageScroll,
							   scrollableRange: (nil, nil))
		
		self.viewStore.publisher.selectedDate.removeDuplicates()
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				self?.weekView.updateWeekView(to: $0)
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
		let endDate = Calendar.current.date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
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
