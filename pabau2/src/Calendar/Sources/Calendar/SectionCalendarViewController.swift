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
		let dataSource = Self.makeSectionDataSource(state: viewStore.state)
		self.sectionDataSource = dataSource
		self.viewStore = viewStore
		super.init()
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
		self.reload(state: viewStore.state)
		calendarView.forceReload()
		viewStore.publisher.removeDuplicates()
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
			.sink(receiveValue: { [weak self] in
				guard let self = self else { return }
                self.reload(state: $0)
			}).store(in: &self.cancellables)
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viewStore.send(.viewDidLayoutSubviews(sectionWidth: Float(calendarView.sectionsFlowLayout.sectionWidth ?? 0)))
	}
	
	func reload(
		state: CalendarSectionViewState<Subsection>
	) {
		calendarView.updateWeekView(to: state.selectedDate)
		sectionDataSource = Self.makeSectionDataSource(state: state)
		calendarView.sectionsDataSource = sectionDataSource
		calendarView.layoutSubviews()
		calendarView.forceReload()
	}
	
	static func makeSectionDataSource(state: CalendarSectionViewState<Subsection>) ->
	SectionWeekViewDataSource<JZAppointmentEvent, Location, Subsection, JZShift> {
		let jzApps = state.appointments.appointments.mapValues { $0.mapValues { $0.mapValues { $0.elements.map(JZAppointmentEvent.init(appointment:)) }}}
		return SectionWeekViewDataSource.init(state.selectedDate,
											  state.chosenLocations(),
											  state.chosenSubsections(),
											  jzApps,
											  state.shifts,
											  state.sectionOffsetIndex,
											  CGFloat(state.sectionWidth ?? 0)
											  )
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
