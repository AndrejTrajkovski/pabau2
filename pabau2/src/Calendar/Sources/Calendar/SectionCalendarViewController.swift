import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture

public class SectionCalendarViewController: BaseCalendarViewController {
		
	var sectionDataSource: SectionDataSource!
	
	override init(_ viewStore: ViewStore<CalendarState, CalendarAction>) {
		super.init(viewStore)
		self.calendarView.viewStore = viewStore
		self.calendarView.sectionsDataSource =
		SectionWeekViewDataSource<AppointmentEvent, Employee.Id>.init()
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
//		let chosenSections = self.viewStore.publisher.chosenEmployeesIds.removeDuplicates()
//			.combineLatest(self.viewStore.publisher.chosenRoomsIds.removeDuplicates())
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
		self.viewStore.publisher.selectedDate
			.removeDuplicates()
			.combineLatest(
				self.viewStore.publisher.calendarType.removeDuplicates()
			)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				print("selected date changed", $0)
				let date = $0
				let calType = $1
				let employeesIds = self!.viewStore.state.employees.map(\.key)
				let roomIds = self!.viewStore.state.rooms.map(\.key)
			    self?.calendarView.updateWeekView(to: date)
				switch calType {
					case .employee(let apps):
						let dataSource = SectionWeekViewDataSource<AppointmentEvent, Employee.Id>.init()
						dataSource.update(date,
										  employeesIds,
										  apps.appointments)
						self?.sectionDataSource = dataSource
						self?.calendarView.sectionsDataSource = dataSource
					case .room(let apps):
						let dataSource = SectionWeekViewDataSource<AppointmentEvent, Room.Id>.init()
						dataSource.update(date,
										  roomIds,
										  apps.appointments)
						self?.sectionDataSource = dataSource
						self?.calendarView.sectionsDataSource = dataSource
					case .week(_): fatalError()
				}
				self?.calendarView.forceReload()
		}).store(in: &self.cancellables)
//		self.viewStore.publisher.calendarType.removeDuplicates())
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - SectionLongPressDelegate
extension SectionCalendarViewController: SectionLongPressDelegate {
	
	public func weekView(_ weekView: JZLongPressWeekView,
						 editingEvent: JZBaseEvent,
						 didEndMoveLongPressAt startDate: Date,
						 endPageAndSectionIdx: (Int?, Int?),
						 startPageAndSectionIdx: (Int?, Int?)) {
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

extension SectionCalendarViewController {
	
	var calendarView: SectionCalendarView {
		return view as! SectionCalendarView
	}

	public override func loadView() {
		view = setupCalendarView()
	}
	
	open func setupCalendarView() -> SectionCalendarView {
		let calendarView = SectionCalendarView.init(frame: .zero)
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
