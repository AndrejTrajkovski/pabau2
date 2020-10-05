import JZCalendarWeekView
import UIKit
import Model

class CalendarDataSource: SectionWeekViewDataSource {
	static let cellId = "CalendarCell"
	
	var employees: [Employee] = Employee.mockEmployees
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if var cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellId, for: indexPath) as? BaseCalendarCell,
			let event = getCurrentEvent(with: indexPath) as? AppointmentEvent {
			CellConfigurator().configure(cell: &cell,
										 appointment: event)
			return cell
		}
		preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		print(kind)
		var view = UICollectionReusableView()
		switch kind {
		case JZSupplementaryViewKinds.columnHeader:
			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: ColumnHeader.self), for: indexPath) as? ColumnHeader {
				if let event = getCurrentEvent(with: indexPath) as? AppointmentEvent,
					let employee = employees.first(where: { event.employeeId == $0.id.rawValue }) {
					columnHeader.update(title: employee.name,
										subtitle: "London",
										color: UIColor.blue)
				} else {
					columnHeader.update(title: "No appointments",
										subtitle: "",
										color: UIColor.clear)
				}
				view = columnHeader
			}
		default: view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
		}
		return view
	}
}
