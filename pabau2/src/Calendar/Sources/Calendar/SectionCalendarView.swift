import JZCalendarWeekView
import UIKit
import Model
import ComposableArchitecture
import SwiftDate

public class SectionCalendarView<Subsection: Identifiable & Equatable>: SectionWeekView<JZAppointmentEvent, Location, Subsection, JZShift> {
	
	let cellId = "CalendarCell"
	let columnHeaderId = "ColumnHeader"
	let columnBackground = "ColumnBackground"
	
	public override func registerViewClasses() {
		super.registerViewClasses()
		collectionView.register(
            BaseCalendarCell.self,
            forCellWithReuseIdentifier: cellId
        )
		collectionView.register(
            ColumnHeader.self,
            forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnHeader,
            withReuseIdentifier: columnHeaderId
        )
		collectionView.register(
            JZColumnBackground.self,
            forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnBackground,
            withReuseIdentifier: columnBackground
        )
	}
	
	func reload(state: CalendarSectionViewState<Subsection>) {
		self.sectionsDataSource = Self.makeSectionDataSource(state: state)
		updateWeekView(to: state.selectedDate)
		layoutSubviews()
		updateAllDayBar(isScrolling: false)
		sectionsFlowLayout.invalidateLayoutCache()
		collectionView.reloadData()
	}

	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? BaseCalendarCell,
			let event = getCurrentEvent(with: indexPath) as? JZAppointmentEvent {
			CellConfigurator().configure(
                cell: &cell,
				appointment: event
            )
			return cell
		}
		preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
	}

	override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		var view = UICollectionReusableView()
		switch kind {
		case JZSupplementaryViewKinds.columnHeader:
			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: columnHeaderId, for: indexPath) as? ColumnHeader {
				let (sectionOpt, subsection) = sectionsDataSource!.sectionAndSubsection(for: indexPath.section)
				if let section = sectionOpt,
				   let viewModel = ColumnHeaderAdapter.sectionViewModel(subsection!, section) {
					columnHeader.update(viewModel: viewModel)
				} else {
					columnHeader.update(title: "", subtitle: "", color: UIColor.clear)
				}
				view = columnHeader
			}
		case JZSupplementaryViewKinds.columnBackground:
			if let columnBackground = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: columnBackground, for: indexPath) as? JZColumnBackground {
				view = columnBackground
			}
		default: view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
		}
		return view
	}

	@objc override public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, backgroundTimesAtSection section: Int) -> [JZBackgroundTime] {
		return sectionsDataSource!.backgroundTimes(section: section)
	}
	
	static func makeSectionDataSource(state: CalendarSectionViewState<Subsection>) ->
	SectionWeekViewDataSource<JZAppointmentEvent, Location, Subsection, JZShift> {
		let jzApps = state.appointments.appointments.mapValues { $0.mapValues { $0.mapValues { $0.elements.map(JZAppointmentEvent.init(appointment:)) }}}
		print("appointments: \(jzApps)")
		return SectionWeekViewDataSource.init(state.selectedDate,
											  state.chosenLocations(),
											  state.chosenSubsections(),
											  jzApps[state.selectedDate] ?? [:],
											  state.shifts[state.selectedDate] ?? [:],
											  CGFloat(state.sectionWidth ?? 0)
		)
	}
}
