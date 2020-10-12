import JZCalendarWeekView
import UIKit
import Model
import ComposableArchitecture

public class CalendarView: SectionWeekView {
	
	static let cellId = "CalendarCell"
	static let columnHeaderId = "ColumnHeader"
	
	var viewStore: ViewStore<CalendarState, CalendarAction>!
	
	public override func registerViewClasses() {
		// Register CollectionViewCell
		super.registerViewClasses()
		collectionView.register(BaseCalendarCell.self,
								forCellWithReuseIdentifier: Self.cellId)
		collectionView.register(ColumnHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnHeader, withReuseIdentifier: Self.columnHeaderId)
	}

	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if var cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellId, for: indexPath) as? BaseCalendarCell,
			let event = getCurrentEvent(with: indexPath) as? AppointmentEvent {
			CellConfigurator().configure(cell: &cell,
										 appointment: event)
			return cell
		}
		preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
	}

	override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		var view = UICollectionReusableView()
		print(kind)
		switch kind {
		case JZSupplementaryViewKinds.columnHeader:
			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Self.columnHeaderId, for: indexPath) as? ColumnHeader {
				guard let (pageIdx, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section) else { break
				}
//				viewStore.state.appointments
				columnHeader.update(title: "title", subtitle: "subtitle", color: UIColor.blue)
				view = columnHeader
			}
		default: view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
		}
		return view
	}
}
