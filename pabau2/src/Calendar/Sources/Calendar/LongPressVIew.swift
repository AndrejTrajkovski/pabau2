import JZCalendarWeekView
import UIKit

class LongPressView: JZLongPressWeekView {
	
	static let cellId = "CalendarCell"
	
	override func registerViewClasses() {
		// Register CollectionViewCell
		collectionView.register(BaseCalendarCell.self,
														forCellWithReuseIdentifier: Self.cellId)
//		self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: "EventCell")
		
		// Register DecorationView: must provide corresponding JZDecorationViewKinds
//		self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
//		self.flowLayout.register(BlackGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
//
		// Register SupplementrayView: must override collectionView viewForSupplementaryElementOfKind
//		collectionView.register(RowHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.rowHeader, withReuseIdentifier: "RowHeader")
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellId, for: indexPath) as? BaseCalendarCell,
				let event = getCurrentEvent(with: indexPath) as? AllDayEvent {
				cell.configureCell(event: event)
				return cell
		}
		preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
	}
}
