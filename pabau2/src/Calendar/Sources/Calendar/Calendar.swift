import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture

public class CalendarViewController: BaseCalendarViewController {
	
	override init(_ viewStore: ViewStore<CalendarState, CalendarAction>) {
		super.init(viewStore)
		self.calendarView.viewStore = viewStore
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
		self.viewStore.publisher.selectedDate
			.removeDuplicates()
			.combineLatest(self.viewStore.publisher.appointments.removeDuplicates()
			.combineLatest(self.viewStore.publisher.calendarType.removeDuplicates()))
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				print("selected date changed", $0)
				let date = $0
				let appointments = $1.0
				let calType = $1.1
			    self?.calendarView.updateWeekView(to: date)
				self?.calendarView.forceSectionReload(reloadEvents: appointments,
												  sectionIds: [],
												  sectionKeyPath: keyPath(calType: calType))
		}).store(in: &self.cancellables)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - SectionLongPressDelegate
extension CalendarViewController: SectionLongPressDelegate {
	
//	fileprivate func maybeUpdateSectionWith(_ endPageAndSectionIdx: (Int?, Int?), _ calEvent: inout CalAppointment) {
//		let (pageIdxOpt, withinSectionIdxOpt) = endPageAndSectionIdx
//		if let pageIdx = pageIdxOpt,
//		   let withinSectionIdx = withinSectionIdxOpt,
//		   let firstSectionApp = calendarView.getFirstEvent(pageIdx, withinSectionIdx) as? AppointmentEvent
//		{
//			update(&calEvent,
//				   viewStore.state.calendarType,
//				   firstSectionApp.app)
//		}
//	}
	
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, endPageAndSectionIdx: (Int?, Int?), startPageAndSectionIdx: (Int?, Int?)) {
		if let appointmentEvent = editingEvent as? AppointmentEvent {
			//TODO: Move this logic to reducer
//			var calEvent = appointmentEvent.app
//			if calEvent.start_date.startOfDay == startDate.startOfDay {
//				maybeUpdateSectionWith(endPageAndSectionIdx, &calEvent)
//			}
//			updateStartTimeOn(&calEvent, startDate)
//			viewStore.send(.replaceAppointment(newApp: AppointmentEvent(appointment: calEvent),
//											   id: calEvent.id))
		}
	}

	public func weekView(_ weekView: JZLongPressWeekView,
						 didEndAddNewLongPressAt
							startDate: Date,
						 pageAndSectionIdx: (Int?, Int?)) {
		//TODO: Move this logic to reducer
//		let endDate = Calendar.current.date(byAdding: .hour, value: weekView.addNewDurationMins/60, to: startDate)!
//		var newApp = CalAppointment.dummyInit(start: startDate, end: endDate)
//		maybeUpdateSectionWith(pageAndSectionIdx, &newApp)
//		viewStore.send(.addAppointment(AppointmentEvent(appointment: newApp)))
	}
}

extension CalendarViewController {

	func keyPath(calType: CalendarType) -> AnyHashableKeyPaths {
		let appkp = \AppointmentEvent.app
		switch calType {
		case .employee:
			let empKp = \CalAppointment.employeeId
			let finalKp = appkp.appending(path: empKp)
			return AnyHashableKeyPath(finalKp)
		case .room:
			let roomKp = \CalAppointment.roomId
			let finalKp = appkp.appending(path: roomKp)
			return AnyHashableKeyPath(finalKp)
		default: fatalError()
		}
	}
	
	private func update(_ appointment: inout AppointmentEvent,
						_ fromApp: AppointmentEvent,
						_ keyPath: AnyHashableKeyPath<AppointmentEvent>) {
		keyPath.set(&appointment, keyPath.get(fromApp))
	}
	
	private func update(_ appointment: inout AppointmentEvent,
						_ calType: CalendarType,
						_ fromApp: AppointmentEvent) {
		update(&appointment,
			   fromApp,
			   keyPath(calType: calType))
	}
}

extension CalendarViewController {
	
	var calendarView: CalendarView {
		return view as! CalendarView
	}

	public override func loadView() {
		view = setupCalendarView()
	}
	
	open func setupCalendarView() -> CalendarView {
		let calendarView = CalendarView.init(frame: .zero)
		calendarView.baseDelegate = self
		calendarView.longPressDataSource = self
//		calendarView.longPressDelegate = self
		calendarView.sectionLongPressDelegate = self
		calendarView.longPressTypes = [.addNew, .move]
		calendarView.addNewDurationMins = 60
		calendarView.moveTimeMinInterval = 15
		return calendarView
	}
}
