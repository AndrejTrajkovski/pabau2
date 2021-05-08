import UIKit
import Model
import JZCalendarWeekView
import SwiftDate
import Util
import ComposableArchitecture
import Appointments

public class SectionCalendarViewController<Subsection: Identifiable & Equatable>: BaseCalendarViewController {
	
	let viewStore: ViewStore<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>>
	
	init(_ viewStore: ViewStore<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>>) {
		
		self.viewStore = viewStore
		super.init()
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		calendarView.setupCalendar(setDate: viewStore.state.selectedDate)
		calendarView.reload(state: viewStore.state)
		
		viewStore.publisher.removeDuplicates()
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
			.sink(receiveValue: { [weak self] in
				guard let self = self else { return }
				self.calendarView.reload(state: $0)
			}).store(in: &self.cancellables)
	}

	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		viewStore.send(.viewDidAppear(sectionWidth: Float(calendarView.getSectionWidth())))
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
	public func weekView<Event, SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, editingEvent: Event, didEndChangeDurationAt endDate: Date, startPageAndSectionIdx: (SectionId?, SubsectionId?)) where Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable {
		guard let section = startPageAndSectionIdx.0,
			  let subsection = startPageAndSectionIdx.1 else { return }
		let keys = (section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.editDuration(endDate: endDate, startKeys: keys, eventId: editingEvent.id))
	}

	public func weekView<SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (SectionId?, SubsectionId?)) where SectionId: Hashable, SubsectionId: Hashable {
		guard let section = pageAndSectionIdx.0,
			  let subsection = pageAndSectionIdx.1 else { return }
		let keys = (section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.addAppointment(startDate: startDate, durationMins: weekView.addNewDurationMins, dropKeys: keys))
	}

	public func weekView<Event, SectionId, SubsectionId>(_ weekView: JZLongPressWeekView, editingEvent: Event, didEndMoveLongPressAt startDate: Date, endPageAndSectionIdx: (SectionId?, SubsectionId?), startPageAndSectionIdx: (SectionId?, SubsectionId?)) where Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable {
		print(startPageAndSectionIdx)
		print(endPageAndSectionIdx)
		guard let section = startPageAndSectionIdx.0,
			  let subsection = startPageAndSectionIdx.1 else { return }
		let startKeys = (section as! Location.ID, subsection as! Subsection.ID)
		guard let section2 = endPageAndSectionIdx.0,
			  let subsection2 = endPageAndSectionIdx.1 else { return }
		let dropKeys = (section2 as! Location.ID, subsection2 as! Subsection.ID)
		viewStore.send(.editSections(startDate: startDate, startKeys: startKeys, dropKeys: dropKeys, eventId: editingEvent.id))
	}

	public func weekView<Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable>
	(_ weekView: JZLongPressWeekView,
	 didSelect editingEvent: Event,
	 startPageAndSectionIdx: (SectionId?, SubsectionId?)) {
		guard let section = startPageAndSectionIdx.0,
			  let subsection = startPageAndSectionIdx.1 else { return }
		let startKeys = (section as! Location.ID, subsection as! Subsection.ID)
		viewStore.send(.onSelect(startKeys: startKeys, eventId: editingEvent.id))
	}

	public func weekView<SectionId: Hashable, SubsectionId: Hashable>
	(_ weekView: JZLongPressWeekView,
	 didTap onDate: Date,
	 startPageAndSectionIdx: (SectionId?, SubsectionId?),
	 anchorView: UIView) {
		guard let section = startPageAndSectionIdx.0,
			  let subsection = startPageAndSectionIdx.1 else { return }
		let startKeys = (section as! Location.ID, subsection as! Subsection.ID)
		presentAlert(onDate, anchorView, weekView,
					 onAddBookout: {
						self.viewStore.send(.addBookout(startDate: onDate, durationMins: weekView.addNewDurationMins, dropKeys: startKeys))
					 }, onAddAppointment: {
						self.viewStore.send(.addAppointment(startDate: onDate, durationMins: weekView.addNewDurationMins, dropKeys: startKeys))
					})
	}
}

extension SectionCalendarViewController {
	
	var calendarView: SectionCalendarView<Subsection> {
		return view as! SectionCalendarView<Subsection>
	}

	open func setupCalendarView() -> SectionCalendarView<Subsection> {
		let calendarView = SectionCalendarView<Subsection>.init(frame: .zero)
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
