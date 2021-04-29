import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Appointments

public class SectionCalendarViewController<Subsection: Identifiable & Equatable>: BaseCalendarViewController {

	var sectionDataSource: SectionWeekViewDataSource<JZAppointmentEvent, Location, Subsection, JZShift>!
	let viewStore: ViewStore<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>>
	
	init(_ viewStore: ViewStore<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>>) {
		let dataSource = SectionWeekViewDataSource<JZAppointmentEvent, Location, Subsection, JZShift>.init()
		self.sectionDataSource = dataSource
		self.viewStore = viewStore
		super.init()
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
		let shifts = viewStore.state.shifts
        self.reload(
            selectedDate: viewStore.state.selectedDate,
            locations: viewStore.state.chosenLocations(),
            subsections: viewStore.state.chosenSubsections(),
            events: viewStore.state.appointments.appointments,
            shifts: shifts,
			sectionOffsetIndex: viewStore.state.sectionOffsetIndex
        )
		calendarView.forceReload()
		viewStore.publisher.selectedDate.removeDuplicates().eraseToAnyPublisher()
			.combineLatest(
				viewStore.publisher.appointments.removeDuplicates().eraseToAnyPublisher()
			).combineLatest(
				viewStore.publisher.chosenSubsectionsIds.removeDuplicates().eraseToAnyPublisher()
			).combineLatest(
				viewStore.publisher.chosenLocationsIds.removeDuplicates().eraseToAnyPublisher()
			).combineLatest(
				viewStore.publisher.shifts.removeDuplicates().eraseToAnyPublisher()
			).combineLatest(
				viewStore.publisher.sectionOffsetIndex.removeDuplicates().eraseToAnyPublisher()
			)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
			.sink(receiveValue: { [weak self] in
                
				guard let self = self else { return }
				let date: Date = $0.0.0.0.0.0
				let events: EventsBy<Subsection> = $0.0.0.0.0.1
				let chosenSubsectionIds:[Location.ID :[Subsection.ID]] = $0.0.0.0.1
//				let subsections: [Location.ID: [Subsection]] = chosenSubsectionIds
//					.filter { self.viewStore.state.chosenLocationsIds.contains($0.key) }
//					.mapValuesFrom(dict: self.viewStore.state.subsections)
				let shifts: [Date: [Location.ID: [Subsection.ID: [JZShift]]]] = $0.0.1
				let sectionOffsetIndex = $0.1
                self.reload(
                    selectedDate: date,
                    locations: self.viewStore.state.chosenLocations(),
                    subsections: self.viewStore.state.chosenSubsections(),
                    events: events.appointments,
                    shifts: shifts,
					sectionOffsetIndex: sectionOffsetIndex
                )
                
			}).store(in: &self.cancellables)
	}

	func reload(
        selectedDate: Date,
		locations: [Location],
		subsections: [Location.ID: [Subsection]],
		events: [Date: [Location.ID: [Subsection.ID: IdentifiedArrayOf<CalendarEvent>]]],
		shifts: [Date: [Location.ID: [Subsection.ID: [JZShift]]]],
		sectionOffsetIndex: Int
	) {
        print(selectedDate)
		calendarView.updateWeekView(to: selectedDate)
        sectionDataSource.update(
            selectedDate,
            locations,
            subsections,
            events.mapValues { $0.mapValues { $0.mapValues { $0.elements.map(JZAppointmentEvent.init(appointment:)) }}},
            shifts,
			viewStore.state.sectionOffsetIndex
        )
		calendarView.layoutSubviews()
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
	public func weekView<Event, SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, editingEvent: Event, didEndChangeDurationAt endDate: Date, startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?)) where Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable {
		guard let date = startPageAndSectionIdx.0,
			  let section = startPageAndSectionIdx.1,
			  let subsection = startPageAndSectionIdx.2 else { return }
		let keys = (date, section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.editDuration(endDate: endDate, startKeys: keys, eventId: editingEvent.id))
	}

	public func weekView<SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Date?, SectionId?, SubsectionId?)) where SectionId: Hashable, SubsectionId: Hashable {
		guard let date = pageAndSectionIdx.0,
			  let section = pageAndSectionIdx.1,
			  let subsection = pageAndSectionIdx.2 else { return }
		let keys = (date, section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.addAppointment(startDate: startDate, durationMins: weekView.addNewDurationMins, dropKeys: keys))
	}

	public func weekView<Event, SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, editingEvent: Event, didEndMoveLongPressAt startDate: Date, endPageAndSectionIdx: (Date?, SectionId?, SubsectionId?), startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?)) where Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable {
		print(startPageAndSectionIdx)
		print(endPageAndSectionIdx)
		guard let date = startPageAndSectionIdx.0,
			  let section = startPageAndSectionIdx.1,
			  let subsection = startPageAndSectionIdx.2 else { return }
		let startKeys = (date, section as! Location.ID, subsection as! Subsection.ID)
		guard let date2 = endPageAndSectionIdx.0,
			  let section2 = endPageAndSectionIdx.1,
			  let subsection2 = endPageAndSectionIdx.2 else { return }
		let dropKeys = (date2, section2 as! Location.ID, subsection2 as! Subsection.ID)
		viewStore.send(.editSections(startDate: startDate, startKeys: startKeys, dropKeys: dropKeys, eventId: editingEvent.id))
	}

	public func weekView<Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable>
	(_ weekView: JZLongPressWeekView,
	 didSelect editingEvent: Event,
	 startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?)) {
		guard let date = startPageAndSectionIdx.0,
			  let section = startPageAndSectionIdx.1,
			  let subsection = startPageAndSectionIdx.2 else { return }
		let startKeys = (date, section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.onSelect(startKeys: startKeys, eventId: editingEvent.id))
	}

	public func weekView<SectionId: Hashable, SubsectionId: Hashable>
	(_ weekView: JZLongPressWeekView,
	 didTap onDate: Date,
	 startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?),
	 anchorView: UIView) {
		guard let date = startPageAndSectionIdx.0,
			  let section = startPageAndSectionIdx.1,
			  let subsection = startPageAndSectionIdx.2 else { return }
		let startKeys = (date, section as! Location.ID, subsection as! Subsection.ID)
		presentAlert(onDate, anchorView, weekView,
					 onAddBookout: {
						self.viewStore.send(.addBookout(startDate: onDate, durationMins: weekView.addNewDurationMins, dropKeys: startKeys))
					 }, onAddAppointment: {
						self.viewStore.send(.addAppointment(startDate: onDate, durationMins: weekView.addNewDurationMins, dropKeys: startKeys))
					})
	}
}

extension SectionCalendarViewController {
	var calendarView: SectionCalendarView<JZAppointmentEvent, Subsection> {
		return view as! SectionCalendarView<JZAppointmentEvent, Subsection>
	}

	open func setupCalendarView() -> SectionCalendarView<JZAppointmentEvent, Subsection> {
		let calendarView = SectionCalendarView<JZAppointmentEvent, Subsection>.init(frame: .zero)
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
