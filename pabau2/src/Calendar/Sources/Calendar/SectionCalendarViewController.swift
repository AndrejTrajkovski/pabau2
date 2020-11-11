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
		guard let date = pageAndSectionIdx.0,
			  let section = pageAndSectionIdx.1,
			  let subsection = pageAndSectionIdx.2 else { return }
		let keys = (date, section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.addAppointment(startDate: startDate, durationMins: weekView.addNewDurationMins, dropKeys: keys))
	}

	public func weekView<Event, SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, editingEvent: Event, didEndMoveLongPressAt startDate: Date, endPageAndSectionIdx: (Date?, SectionId?, SubsectionId?), startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?)) where Event : JZBaseEvent, SectionId : Hashable, SubsectionId : Hashable {
		print(startPageAndSectionIdx)
		print(endPageAndSectionIdx)
		guard let date = startPageAndSectionIdx.0,
			  let section = startPageAndSectionIdx.1,
			  let subsection = startPageAndSectionIdx.2 else { return }
		let startKeys = (date, section as! Location.ID, subsection as! Subsection.ID)
		guard let date2 = endPageAndSectionIdx.0,
			  let section2 = endPageAndSectionIdx.1,
			  let subsection2 = endPageAndSectionIdx.2 else { return }
		let dropKeys = (date, section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.editAppointment(startDate: startDate, startKeys: startKeys, dropKeys: dropKeys))
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
