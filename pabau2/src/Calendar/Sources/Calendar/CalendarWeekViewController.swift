import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine
import Overture

public class CalendarWeekViewController: BaseCalendarViewController {

	let viewStore: ViewStore<CalendarWeekViewState, CalendarWeekViewAction>

	init(_ viewStore: ViewStore<CalendarWeekViewState, CalendarWeekViewAction>) {
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
		self.viewStore.publisher.selectedDate
			.combineLatest(self.viewStore.publisher.appointments)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				let newInitDate = $0.0.getMondayOfWeek()
				self?.weekView.updateWeekView(to: newInitDate)
				self?.weekView.forceReload(reloadEvents: $0.1.mapValues(pipe(get(\.elements), map(JZAppointmentEvent.init(appointment:)))))
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
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndChangeDurationLongPressAt endDate: Date, startOfDayDate: Date) {
		viewStore.send(.editDuration(startOfDayDate: startOfDayDate, endDate: endDate, eventId: editingEvent.id))
	}

	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, startOfDayDate: Date) {
		viewStore.send(.addAppointment(startOfDayDate: startOfDayDate, startDate: startDate, durationMins: weekView.addNewDurationMins))
	}

	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, startOfDayDate: Date, startingPointStartOfDay: Date) {
		viewStore.send(.editStartTime(startOfDayDate: startOfDayDate, startDate: startDate, eventId: editingEvent.id, startingPointStartOfDay: startingPointStartOfDay))
	}
	
	public func weekView(_ weekView: JZLongPressWeekView, didTapOn date: Date, startOfDayDate: Date, anchorView: UIView) {
		presentAlert(date, anchorView, startOfDayDate, weekView,
					 onAddBookout: {
						self.viewStore.send(.addBookout(startOfDayDate: startOfDayDate, startDate: date, durationMins: weekView.addNewDurationMins))
					 }, onAddAppointment: {
						self.viewStore.send(.addAppointment(startOfDayDate: startOfDayDate, startDate: date, durationMins: weekView.addNewDurationMins))
					})
	}
}
