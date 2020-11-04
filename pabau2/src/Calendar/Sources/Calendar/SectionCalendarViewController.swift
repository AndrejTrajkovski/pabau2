import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture

public class SectionCalendarViewController<Event: JZBaseEvent, Subsection: Identifiable & Equatable>: BaseCalendarViewController {
	
	var sectionDataSource: SectionWeekViewDataSource<Event, Location, Subsection>!
	let viewStore: ViewStore<CalendarSectionViewState<Event, Subsection>, CalendarAction>
	init(_ viewStore: ViewStore<CalendarSectionViewState<Event, Subsection>, CalendarAction>) {
		let dataSource = SectionWeekViewDataSource<Event, Location, Subsection>.init()
		self.sectionDataSource = dataSource
		self.viewStore = viewStore
		super.init(onFlipPage: { viewStore.send(.userDidSwipePageTo(isNext: $0)) })
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
//		sectionDataSource.update(viewStore.state.selectedDate,
//								 viewStore.state.chosenSections(),
//								 viewStore.state.appointments.appointments)
//		calendarView.forceReload()
		self.viewStore.publisher.selectedDate.removeDuplicates()
			.combineLatest(
				self.viewStore.publisher.appointments.removeDuplicates()
			).combineLatest(
				self.viewStore.publisher.chosenSubsectionsIds.removeDuplicates()
			).combineLatest(
				self.viewStore.publisher.chosenLocationsIds.removeDuplicates()
			)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				guard let self = self else { return }
				let date = $0.0.0.0
				let events = $0.0.0.1
				let subsections = $0.0.1
				let chosenLocationsIds = $0.1
				let locations = chosenLocationsIds.compactMap {
					self.viewStore.state.locations[id: $0]
				}
				print(events.appointments)
				print(locations)
				print(subsections)
				self.reload(selectedDate: date,
							locations: locations,
							subsections: subsections,
							events: events.appointments)
			}).store(in: &self.cancellables)
		//		self.viewStore.publisher.calendarType.removeDuplicates())
	}
	
	func reload(
		selectedDate: Date,
		locations: [Location],
		subsections: [Location.ID: [Subsection.ID]],
		events: [Date: [Location.ID: [Subsection.ID: [Event]]]]
	) {
		calendarView.updateWeekView(to: selectedDate)
		sectionDataSource.update(selectedDate,
									  locations,
									  subsections,
									  events)
		calendarView.forceReload()
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
	public func weekView<SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Date?, SectionId?, SubsectionId?)) where SectionId : Hashable, SubsectionId : Hashable {
		print(pageAndSectionIdx)
	}
	
	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Date?, Location.ID?, Subsection.ID?)) {
		
	}
	
	public func weekView<Event, SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, editingEvent: Event, didEndMoveLongPressAt startDate: Date, endPageAndSectionIdx: (Date?, SectionId?, SubsectionId?), startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?)) where Event : JZBaseEvent, SectionId : Hashable, SubsectionId : Hashable {
		print(startPageAndSectionIdx)
		print(endPageAndSectionIdx)
	}
	
	
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
	
	var calendarView: SectionCalendarView<Event, Subsection> {
		return view as! SectionCalendarView<Event, Subsection>
	}
	
	open func setupCalendarView() -> SectionCalendarView<Event, Subsection> {
		let calendarView = SectionCalendarView<Event, Subsection>.init(frame: .zero)
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
