import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Combine

public class CalendarViewController: UIViewController {

	let viewStore: ViewStore<CalendarState, CalendarAction>
	var cancellables: Set<AnyCancellable> = []
	
	init(_ viewStore: ViewStore<CalendarState, CalendarAction>) {
		self.viewStore = viewStore
		super.init(nibName: nil, bundle: nil)
		self.calendarView.viewStore = viewStore
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

	public override func viewDidLoad() {
		super.viewDidLoad()
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate,
								   events: [:])
//		self.viewStore.publisher.selectedCalType
//			.map(keyPath(calType:))
//			.receive(on: DispatchQueue.main)
//			.assign(to: \.groupingProperty, on: grouper)
//			.store(in: &self.cancellables)
		self.viewStore.publisher.selectedDate.removeDuplicates()
			.combineLatest(self.viewStore.publisher.appointments.removeDuplicates())
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				print("selected date changed", $0)
			self?.calendarView.updateWeekView(to: $0)
			self?.calendarView.forceSectionReload(reloadEvents: $1)
		}).store(in: &self.cancellables)
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
}

extension CalendarViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {

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
		//compare in order not to go in an infinite loop
		let dateDisplayed = initDate + (weekView.numOfDays).days //JZCalendar holds previous and next pages in cache, initDate is not the date displayed on screen
		if self.viewStore.state.selectedDate.compare(toDate: dateDisplayed, granularity: .day) != .orderedSame {
			print("send(.datePicker(.selectedDate(dateDisplayed)))", initDate)
			self.viewStore.send(.datePicker(.selectedDate(dateDisplayed)))
		}
	}
}

// MARK: - SectionLongPressDelegate
extension CalendarViewController: SectionLongPressDelegate {
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {
		if var appointmentEvent = editingEvent as? AppointmentEvent {
			
		} else {
			fatalError()
		}
	}

	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {
	
	}
}

extension CalendarViewController {
	
	func keyPath(calType: CalendarType) -> AnyHashableKeyPath<AppointmentEvent> {
		let appKp = \AppointmentEvent.app
		switch calType {
		case .employee:
			let kpe = appKp.appending(path: \CalAppointment.employeeId)
			return AnyHashableKeyPath(kpe)
		case .room:
			let kps = appKp.appending(path: \CalAppointment.roomId)
			return AnyHashableKeyPath(kps)
		default: fatalError()
		}
	}
}
