import JZCalendarWeekView
import UIKit
import Model
import ComposableArchitecture

class CalendarWeekView: JZLongPressWeekView {
	static let cellId = "CalendarCell"
	static let columnHeaderId = "ColumnHeader"

	var viewStore: ViewStore<CalendarState, CalendarAction>!
	public override func registerViewClasses() {
		// Register CollectionViewCell
		super.registerViewClasses()
		collectionView.register(BaseCalendarCell.self,
								forCellWithReuseIdentifier: Self.cellId)
//		collectionView.register(ColumnHeader.self, forSupplementaryViewOfKind: JZSupplementaryViewKinds.columnHeader, withReuseIdentifier: Self.columnHeaderId)
	}

	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if var cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellId, for: indexPath) as? BaseCalendarCell,
			let event = getCurrentEvent(with: indexPath) as? JZAppointmentEvent {
			CellConfigurator().configure(
                cell: &cell,
				appointment: event
            )
			return cell
		}
		preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
	}

//	override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//		var view = UICollectionReusableView()
//		switch kind {
//		case JZSupplementaryViewKinds.columnHeader:
//			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Self.columnHeaderId, for: indexPath) as? ColumnHeader {
//				if let firstSectionApp = getFirstEventAt(indexPath.section) as? AppointmentEvent {
//					let viewModel = ColumnHeaderAdapter.makeViewModel(
//						firstSectionApp, viewStore.state.Type, viewStore.state.locations, viewStore.state.rooms, viewStore.state.employees, Calendar.gregorian.startOfDay(for: firstSectionApp.startDate))
//					columnHeader.update(viewModel: viewModel)
//				} else {
//					columnHeader.update(title: "", subtitle: "", color: UIColor.clear)
//				}
//				view = columnHeader
//			}
//		default: view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
//		}
//		return view
//	}
}
