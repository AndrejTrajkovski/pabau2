import JZCalendarWeekView
import UIKit

class CalendarView: SectionWeekView {
	
	static let cellId = "CalendarCell"
	
	override func registerViewClasses() {
		// Register CollectionViewCell
		//		super.registerViewClasses()
		collectionView.register(BaseCalendarCell.self,
								forCellWithReuseIdentifier: Self.cellId)
		
		self.collectionView.registerSupplimentaryViews([JZColumnHeader.self, JZCornerHeader.self, JZRowHeader.self, JZAllDayHeader.self, ColumnHeader.self])
		// decoration
		flowLayout.registerDecorationViews([JZColumnHeaderBackground.self, JZRowHeaderBackground.self,
											JZAllDayHeaderBackground.self, JZAllDayCorner.self])
		flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
		flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
		collectionView.register(ColumnHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnHeader, withReuseIdentifier: "ColumnHeader")
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
		case "ColumnHeader":
			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? ColumnHeader {
				view = columnHeader
			}
		default: view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
		}
		return view
	}
}
