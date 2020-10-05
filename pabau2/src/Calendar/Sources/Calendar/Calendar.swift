import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine

struct TestType {}
public class CalendarViewController: UIViewController {
	
	var employeeKeyPath = \AppointmentEvent.employeeId
	var roomKeyPath = \AppointmentEvent.roomId
	var grouper: HashableValueWritableKeyPath!
	
	let viewStore: ViewStore<CalendarState, CalendarAction>
	var cancellables: Set<AnyCancellable> = []
	
	init(_ viewStore: ViewStore<CalendarState, CalendarAction>) {
		self.viewStore = viewStore
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	weak var calendarView: CalendarView!
	var appointments = CalAppointment.makeDummy()
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		grouper = HashableValueWritableKeyPath(\AppointmentEvent.roomId)
		grouper = HashableValueWritableKeyPath(\AppointmentEvent.employeeId)
		grouper = HashableValueWritableKeyPath(\AppointmentEvent.service)
		setupCalendarView()
		calendarView.setupCalendar(setDate: Date(),
								   events: [:])
		self.viewStore.publisher.selectedCalType.removeDuplicates().sink(receiveValue: { [weak self] _ in
			
		}).store(in: &self.cancellables)
		self.viewStore.publisher.selectedDate.removeDuplicates().sink(receiveValue: { [weak self] in
			self?.calendarView.updateWeekView(to: $0)
		}).store(in: &self.cancellables)
		DispatchQueue.main.async {
			self.reloadData()
		}
	}

	func setupCalendarView() {
		let calendarView = makeCalendarView()
		calendarView.baseDelegate = self
		calendarView.sectionLongPressDelegate = self
		calendarView.longPressDelegate = self
		calendarView.longPressDataSource = self
		calendarView.longPressTypes = [.addNew, .move]
		calendarView.addNewDurationMins = 60
		calendarView.moveTimeMinInterval = 15
		self.calendarView = calendarView
	}
	
	func makeCalendarView() -> CalendarView {
		let calendarView = CalendarView.init(frame: .zero)
			calendarView.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(calendarView)
		NSLayoutConstraint.activate([
			calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
					calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
					calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 0)
		])
		return calendarView
	}

	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarView)
	}
	
	func reloadData() {
//		let keyPath = viewStore.state.selectedCalType == .employee ?  : \AppointmentEvent.service
		let events = self.appointments.map(AppointmentMaker.makeAppointmentEvent(_:))
		let byDate: [Date: [AppointmentEvent]] = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
		byDate.mapValues(employeeGrouper)
		calendarView.forceSectionReload(reloadEvents: sorted)
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
			viewStore.send(.datePicker(.selectedDate(dateDisplayed)))
		}
	}
}

// MARK: - SectionLongPressDelegate
extension CalendarViewController: SectionLongPressDelegate {
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {
		
	}

	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {

	}
}

struct HashableValueWritableKeyPath {
	
	let access: (AppointmentEvent) -> AnyHashable
	let update: (inout AppointmentEvent, AnyHashable) -> ()
	
	init<T: Hashable>(_ kp: WritableKeyPath<AppointmentEvent, T>) {
		update = {
			$0[keyPath: kp] = $1.base as! T
		}
		
		access = {
			$0[keyPath: kp]
		}
	}
}

class BaseAppointmentGrouper {
	
	public typealias SectionSort = ((key: AnyHashable, value: [AppointmentEvent]),
									(key: AnyHashable, value: [AppointmentEvent])) -> Bool
	
	var events: [[AppointmentEvent]] = []
	public var groupingProperty: HashableValueWritableKeyPath
	var sorting: SectionSort
	
	public init(groupingProperty: HashableValueWritableKeyPath,
				sorting: @escaping SectionSort) {
		self.groupingProperty = groupingProperty
	}
	
	func update(events: [AppointmentEvent]) {
		self.events = groupAndSortSections(
			grouping: groupingProperty,
			sorting: sorting)(events)
	}
	
	func groupAndSortSections(
		grouping: HashableValueWritableKeyPath,
		sorting: @escaping SectionSort
	)
	-> ([AppointmentEvent]) -> [[AppointmentEvent]] {
		return { events in
			let grouped = Dictionary.init(grouping: events,
										  by: {
											return grouping.access($0) })
			let sorted = grouped.sorted(by: sorting)
			return sorted.map(\.value)
		}
	}
	
	func getGroupOf(event indexes: (page: Int, withinPage: Int)) -> AnyHashable {
		let event = events[indexes.page][indexes.withinPage]
		return groupingProperty.access(event)
	}
}
