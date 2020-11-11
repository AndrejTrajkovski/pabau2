import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture

public class SectionCalendarViewController<Event: JZBaseEvent, Subsection: Identifiable & Equatable>: BaseCalendarViewController {

	var sectionDataSource: SectionWeekViewDataSource<Event, Location, Subsection, JZShift>!
	let viewStore: ViewStore<CalendarSectionViewState<Event, Subsection>, SubsectionCalendarAction<Subsection>>
	init(_ viewStore: ViewStore<CalendarSectionViewState<Event, Subsection>, SubsectionCalendarAction<Subsection>>) {
		let dataSource = SectionWeekViewDataSource<Event, Location, Subsection, JZShift>.init()
		self.sectionDataSource = dataSource
		self.viewStore = viewStore
		super.init()
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
		let subs = viewStore.state.chosenSubsectionsIds.mapValuesFrom(dict: viewStore.state.subsections)
		let shifts = viewStore.state.shifts
		self.reload(selectedDate: viewStore.state.selectedDate,
					locations: viewStore.state.chosenLocations(),
					subsections: subs,
					events: viewStore.state.appointments.appointments,
					shifts: shifts)
		calendarView.forceReload()
		viewStore.publisher.selectedDate.removeDuplicates()
			.combineLatest(
				viewStore.publisher.appointments.removeDuplicates()
			).combineLatest(
				viewStore.publisher.chosenSubsectionsIds.removeDuplicates()
			).combineLatest(
				viewStore.publisher.chosenLocationsIds.removeDuplicates()
			).combineLatest(
				viewStore.publisher.shifts.removeDuplicates()
			)
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] in
				guard let self = self else { return }
				let date = $0.0.0.0.0
				let events = $0.0.0.0.1
				let subsections = $0.0.0.1.mapValuesFrom(dict: self.viewStore.state.subsections)
				let shifts = $0.1
				self.reload(selectedDate: date,
							locations: self.viewStore.state.chosenLocations(),
							subsections: subsections,
							events: events.appointments,
							shifts: shifts)
			}).store(in: &self.cancellables)
	}

	func reload(
		selectedDate: Date,
		locations: [Location],
		subsections: [Location.ID: [Subsection]],
		events: [Date: [Location.ID: [Subsection.ID: [Event]]]],
		shifts: [Date: [Location.ID: [Subsection.ID: [JZShift]]]]
	) {
		calendarView.updateWeekView(to: selectedDate)
		sectionDataSource.update(selectedDate,
									  locations,
									  subsections,
									  events,
									  shifts)
		calendarView.forceReload()
	}

	public override func loadView() {
		view = setupCalendarView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func userDidFlipPage(_ weekView: JZBaseWeekView, isNextPage: Bool) {
		viewStore.send(.onPageSwipe(isNext: isNextPage))
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
		//TODO
		print(startPageAndSectionIdx)
		print(endPageAndSectionIdx)
	}

	public func weekView(_ weekView: JZLongPressWeekView,
						 editingEvent: JZBaseEvent,
						 didEndMoveLongPressAt startDate: Date,
						 endPageAndSectionIdx: (Int?, Int?),
						 startPageAndSectionIdx: (Int?, Int?)) {
		if let appointmentEvent = editingEvent as? JZAppointmentEvent {
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
