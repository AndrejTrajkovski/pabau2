import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine

public class CalendarViewController: UIViewController {
	
	var grouper: BaseAppointmentGrouper!

	let viewStore: ViewStore<CalendarState, CalendarAction>
	var cancellables: Set<AnyCancellable> = []

	init(_ viewStore: ViewStore<CalendarState, CalendarAction>) {
		self.viewStore = viewStore
		super.init(nibName: nil, bundle: nil)
	}
	
	var calendarView: CalendarView {
		return view as! CalendarView
	}
	
	public override func loadView() {
		view = setupCalendarView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var appointments = CalAppointment.makeDummy()
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		grouper = BaseAppointmentGrouper.init(groupingProperty: AnyHashableKeyPath(\AppointmentEvent.employeeId))
		self.viewStore.publisher.selectedDate.removeDuplicates()
			.receive(on: RunLoop.main)
			.sink(receiveValue: { [weak self] in
			self?.calendarView.updateWeekView(to: $0)
		}).store(in: &self.cancellables)
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		calendarView.setupCalendar(setDate: Date(),
								   events: [:])
		reloadData()
	}

	func setupCalendarView() -> CalendarView {
		let calendarView = CalendarView.init(frame: .zero)
		calendarView.baseDelegate = self
		calendarView.sectionLongPressDelegate = self
		calendarView.longPressDelegate = self
		calendarView.longPressDataSource = self
		calendarView.longPressTypes = [.addNew, .move]
		calendarView.addNewDurationMins = 60
		calendarView.moveTimeMinInterval = 15
		return calendarView
	}

	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarView)
	}
	
	func reloadData() {
//		let keyPath = viewStore.state.selectedCalType == .employee ?  : \AppointmentEvent.service
		let events = self.appointments.map(AppointmentAdapter.makeAppointmentEvent(_:))
		let byDate: [Date: [AppointmentEvent]] = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
		let grouped: [Date: [[AppointmentEvent]]] = byDate.mapValues {
			grouper.update(events: $0)
			return grouper.events
		}
		calendarView.forceSectionReload(reloadEvents: grouped)
	}
}

extension CalendarViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {

	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
		let endDate = Calendar.current.date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
		let newApp = CalAppointment.dummyInit(start: startDate, end: endDate)
		self.appointments.append(newApp)
		self.reloadData()
	}

	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
		guard let app = editingEvent as? AppointmentEvent else { return }
		let duration = Calendar.current.dateComponents([.minute], from: app.startDate, to: app.endDate).minute!
		let selectedIndex = self.appointments.firstIndex(where: { $0.id.rawValue == app.id })!
		let startTime = startDate.separateHMSandYMD().0!
		appointments[selectedIndex].start_time = startTime
		appointments[selectedIndex].end_time = Calendar.current.date(byAdding: .minute, value: duration, to: startTime)!
		self.reloadData()
	}

	public func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
		let cell = BaseCalendarCell(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
		cell.layoutSubviews()
		cell.title.text = "New Appointment"
		cell.contentView.backgroundColor = UIColor(hex: 0xEEF7FF)
		cell.colorBlock.backgroundColor = UIColor(hex: 0x0899FF)
		return cell
	}
}

extension CalendarViewController: JZBaseViewDelegate {
	public func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
		let dateDisplayed = initDate + (weekView.numOfDays).days //JZCalendar holds previous and next pages in cache, initDate is not the date displayed on screen
		if viewStore.state.selectedDate.compare(toDate: dateDisplayed, granularity: .day) != .orderedSame {
			//compare in order not to go in an infinite loop
			DispatchQueue.main.async {
				self.viewStore.send(.datePicker(.selectedDate(dateDisplayed)))
			}
		}
	}
}

// MARK: - SectionLongPressDelegate
extension CalendarViewController: SectionLongPressDelegate {
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {
		if var appointmentEvent = editingEvent as? AppointmentEvent {
			grouper.update(event: &appointmentEvent,
						   indexes: pageAndSectionIdx)
			grouper.update(events: <#T##[AppointmentEvent]#>)
		} else {
			fatalError()
		}
	}

	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {
		
	}
}
