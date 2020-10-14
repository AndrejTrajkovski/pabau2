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
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, pageAndSectionIdx: (Int?, Int?), startingIndexPath: IndexPath) {
		let calendarView = weekView as! CalendarView
		if let appointmentEvent = editingEvent as? AppointmentEvent {
			var flat = viewStore.state.appointments.flatMap { $0.value }.flatMap { $0 }
			let flatIndex = flat.firstIndex(where: { $0.id == appointmentEvent.id })
			var calEvent = appointmentEvent.app
			let duration = Calendar.current.dateComponents([.minute], from: calEvent.start_time, to: calEvent.end_time).minute!
			let splitNewDate = startDate.split()
			calEvent.start_date = splitNewDate.ymd
			calEvent.start_time = splitNewDate.hms
			calEvent.end_time = Calendar.current.date(byAdding: .minute, value: duration, to: splitNewDate.hms)!
			
			let (pageIdxOpt, withinSectionIdxOpt) = pageAndSectionIdx
			guard let pageIdx = pageIdxOpt,
				  let withinSectionIdx = withinSectionIdxOpt else {
				return
			}
			if let firstSectionApp = calendarView.getFirstEvent(pageIdx, withinSectionIdx) as? AppointmentEvent {
				update(&calEvent,
					   viewStore.state.calendarType,
					   firstSectionApp)
			}
			flatIndex.map {
				flat[$0] = AppointmentEvent(appointment: calEvent)
			}
			viewStore.send(.reloadApps(flat))
		}
	}

	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Int?, Int?)) {
	}
}

extension CalendarViewController {
	
//	func keyPath(calType: CalendarType) -> AnyHashableKeyPath<AppointmentEvent> {
//		let appKp = \AppointmentEvent.app
//		switch calType {
//		case .employee:
//			let kpe = appKp.appending(path: \CalAppointment.employeeId)
//			return AnyHashableKeyPath(kpe)
//		case .room:
//			let kps = appKp.appending(path: \CalAppointment.roomId)
//			return AnyHashableKeyPath(kps)
//		default: fatalError()
//		}
//	}
//
//	private func update(_ appointment: inout AppointmentEvent,
//						_ fromApp: AppointmentEvent,
//						_ keyPath: AnyHashableKeyPath<AppointmentEvent>) {
//		keyPath.set(&appointment, keyPath.get(fromApp))
//	}
	
	private func update(_ appointment: inout CalAppointment,
						_ calType: CalendarType,
						_ fromApp: AppointmentEvent) {
		if calType == .room {
			appointment.roomId = fromApp.app.roomId
		} else if calType == .day {
			appointment.employeeId = fromApp.app.employeeId
		}
	}
}
