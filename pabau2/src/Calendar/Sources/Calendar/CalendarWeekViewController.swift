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
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndChangeDurationLongPressAt endDate: Date) {
		viewStore.send(.editDuration(endDate: endDate, startOfDayDate: <#T##Date#>, eventId: <#T##Int#>))
	}
	
	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
		
//		let endDate = Calendar.gregorian.date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
//		let newApp = JZAppointmentEvent(appointment: CalAppointment.dummyInit(start: startDate, end: endDate))
//		viewStore.send(.addAppointment(newApp))
	}

	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
		guard let app = editingEvent as? JZAppointmentEvent else { return }
//		let newApp = JZAppointmentEvent(appointment: calApp)
//		viewStore.send(.replaceAppointment(newApp: newApp,
//										   id: app.app.id))
	}
}
