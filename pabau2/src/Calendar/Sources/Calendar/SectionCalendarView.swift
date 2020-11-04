import JZCalendarWeekView
import UIKit
import Model
import ComposableArchitecture

public class SectionCalendarView<E: JZBaseEvent, Subsection: Identifiable & Equatable>: SectionWeekView <E, Location, Subsection> {
	
	let cellId = "CalendarCell"
	let columnHeaderId = "ColumnHeader"
	let columnBackground = "ColumnBackground"
	
	public override func registerViewClasses() {
		// Register CollectionViewCell
		super.registerViewClasses()
		collectionView.register(BaseCalendarCell.self,
								forCellWithReuseIdentifier: cellId)
		collectionView.register(ColumnHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnHeader, withReuseIdentifier: columnHeaderId)
		collectionView.register(JZColumnBackground.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnBackground, withReuseIdentifier: columnBackground)
	}

	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? BaseCalendarCell,
			let event = getCurrentEvent(with: indexPath) as? AppointmentEvent {
			CellConfigurator().configure(cell: &cell,
										 appointment: event)
			return cell
		}
		preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
	}
	
	override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		var view = UICollectionReusableView()
		switch kind {
		case JZSupplementaryViewKinds.columnHeader:
			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: columnHeaderId, for: indexPath) as? ColumnHeader {
//				let section = sectionsDataSource!.section(for: indexPath.section)
//				let location =
//				if let viewModel = ColumnHeaderAdapter.sectionViewModel(section, location) {
//					columnHeader.update(viewModel: viewModel)
//				} else {
//					columnHeader.update(title: "", subtitle: "", color: UIColor.clear)
//				}
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
}
