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
		//FIXME: Should lookup in paging dates not in view store!
		switch kind {
		case JZSupplementaryViewKinds.columnHeader:
			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Self.columnHeaderId, for: indexPath) as? ColumnHeader {
				guard let (pageIdx, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section) else {
					columnHeader.update(title: "", subtitle: "", color: UIColor.clear)
					break
				}
				let firstSectionApp = getFirstEvent(pageIdx, withinPageIdx) as? AppointmentEvent
				if viewStore.state.calendarType == .room,
				   let firstSectionApp = firstSectionApp {
					let room = viewStore.state.rooms[firstSectionApp.app.roomId]
					let location = viewStore.state.locations[room!.locationId]
					columnHeader.update(viewModel: RoomHeaderAdapter().viewModel(room: room, location: location))
				} else if viewStore.state.calendarType == .employee,
						  let firstSectionApp = firstSectionApp {
					 let employee = viewStore.state.employees[firstSectionApp.app.employeeId]
					 let location = viewStore.state.locations[firstSectionApp.app.locationId]
					 columnHeader.update(viewModel: RoomHeaderAdapter().viewModel(employee: employee, location: location))
				} else {
					columnHeader.update(title: "", subtitle: "", color: UIColor.clear)
				}
				view = columnHeader
			}
		default: view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
		}
		return view
	}

//	func getRoomId(page: Int, section: Int) -> Room.Id? {
//		return roomIds(page: page)?[safe: section]
//	}
//
//	func roomIds(page: Int) -> [Room.Id]? {
//		return getEvents(page)?.first?.map(\.app.roomId)
//	}
}
