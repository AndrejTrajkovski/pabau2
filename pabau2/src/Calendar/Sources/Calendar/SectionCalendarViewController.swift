import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture

public class SectionCalendarViewController<Event: JZBaseEvent, Section: Identifiable & Equatable>: BaseCalendarViewController {
	
	var sectionDataSource: SectionWeekViewDataSource<Event, Section.ID>!
	let viewStore: ViewStore<CalendarSectionViewState<Event, Section>, CalendarAction>
	init(_ viewStore: ViewStore<CalendarSectionViewState<Event, Section>, CalendarAction>) {
		let dataSource = SectionWeekViewDataSource<Event, Section.ID>.init()
		self.sectionDataSource = dataSource
		self.viewStore = viewStore
		super.init(onFlipPage: { viewStore.send(.userDidSwipePageTo(isNext: $0)) })
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		//		let chosenSections = self.viewStore.publisher.chosenEmployeesIds.removeDuplicates()
		//			.combineLatest(self.viewStore.publisher.chosenRoomsIds.removeDuplicates())
		
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
		sectionDataSource.update(viewStore.state.selectedDate,
								 viewStore.state.chosenSectionsIds,
								 viewStore.state.appointments.appointments)
		calendarView.forceReload()
		self.viewStore.publisher.selectedDate
			.removeDuplicates()
			.combineLatest(
				self.viewStore.publisher.appointments.removeDuplicates()
					.combineLatest(
						self.viewStore.publisher.chosenSectionsIds.removeDuplicates()
					)
			)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				print("selected date changed", $0)
				let date = $0
				let appointments = $1.0
				let sectionIds = $1.1
				self?.calendarView.updateWeekView(to: date)
				self?.sectionDataSource.update(date,
											   sectionIds,
											   appointments.appointments)
				self?.calendarView.forceReload()
			}).store(in: &self.cancellables)
		//		self.viewStore.publisher.calendarType.removeDuplicates())
	}
	
	public override func loadView() {
		view = setupCalendarView()
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
	
	var calendarView: SectionCalendarView<Event, Section.ID> {
		return view as! SectionCalendarView<Event, Section.ID>
	}
	
	open func setupCalendarView() -> SectionCalendarView<Event, Section.ID> {
		let calendarView = SectionCalendarView<Event, Section.ID>.init(frame: .zero)
		calendarView.sectionsDataSource = sectionDataSource
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
