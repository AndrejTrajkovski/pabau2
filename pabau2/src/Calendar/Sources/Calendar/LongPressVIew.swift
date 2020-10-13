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
				if let firstSectionApp = getFirstEventAt(indexPath.section) as? AppointmentEvent {
					configure(firstSectionApp, columnHeader)
				} else {
					columnHeader.update(title: "", subtitle: "", color: UIColor.clear)
				}
				view = columnHeader
			}
		default: view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
		}
		return view
	}

	private func configure(_ firstSectionApp: AppointmentEvent, _ columnHeader: ColumnHeader) {
		let location = viewStore.state.locations[firstSectionApp.app.locationId]
		if viewStore.state.calendarType == .room {
			let room = viewStore.state.rooms[firstSectionApp.app.roomId]
			columnHeader.update(viewModel: RoomHeaderAdapter().viewModel(room: room, location: location))
		} else if viewStore.state.calendarType == .employee {
			let employee = viewStore.state.employees[firstSectionApp.app.employeeId]
			columnHeader.update(viewModel: RoomHeaderAdapter().viewModel(employee: employee, location: location))
		}
	}

//	func getRoomId(page: Int, section: Int) -> Room.Id? {
//		return roomIds(page: page)?[safe: section]
//	}
//
//	func roomIds(page: Int) -> [Room.Id]? {
//		return getEvents(page)?.first?.map(\.app.roomId)
//	}
}
