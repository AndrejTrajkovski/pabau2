import JZCalendarWeekView
import UIKit

class CalendarView: SectionWeekView {
	
	static let cellId = "CalendarCell"
	
	override func registerViewClasses() {
		// Register CollectionViewCell
		//		super.registerViewClasses()
		collectionView.register(BaseCalendarCell.self,
								forCellWithReuseIdentifier: Self.cellId)
		
		self.collectionView.registerSupplimentaryViews([JZCornerHeader.self, JZRowHeader.self, JZAllDayHeader.self, ColumnHeader.self])
		// decoration
		flowLayout.registerDecorationViews([JZColumnHeaderBackground.self, JZRowHeaderBackground.self,
											JZAllDayHeaderBackground.self, JZAllDayCorner.self])
		flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.verticalGridline)
		flowLayout.register(JZGridLine.self, forDecorationViewOfKind: JZDecorationViewKinds.horizontalGridline)
		
		collectionView.register(ColumnHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnHeader, withReuseIdentifier: "ColumnHeader")
	}
}
