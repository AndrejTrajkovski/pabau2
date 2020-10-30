import Model
import ComposableArchitecture
import UIKit

enum ColumnHeaderAdapter {
	
	static func makeViewModel(_ firstSectionApp: AppointmentEvent,
							  _ calType: CalendarType,
							  _ locations: [Location.Id: Location],
							  _ rooms: [Room.Id: Room],
							  _ employees: [Employee.Id: Employee],
							  _ startOfDay: Date) -> ColumnHeaderViewModel {
		switch calType {
		case .room:
			let room = rooms[firstSectionApp.app.roomId]
			let location = room.flatMap { locations[$0.locationId] }
			return viewModel(room: room, location: location)
		case .employee:
			let employee = employees[firstSectionApp.app.employeeId]
			let location = employee.flatMap { locations[$0.locationId] }
			return viewModel(employee: employee, location: location)
		case .week:
			let formatter = DateFormatter()
			formatter.dateStyle = .short
			let date = formatter.string(from: startOfDay)
			formatter.dateFormat = "EEEE"
			let dayOfWeek = formatter.string(from: startOfDay)
			return ColumnHeaderViewModel(title: date, subtitle: dayOfWeek, color: UIColor.clear)
		}
	}
	
	static func viewModel(room: Room?,
						  location: Location?) -> ColumnHeaderViewModel {
		let color = location?.color != nil ? UIColor.fromHex(location!.color) : UIColor.clear
		return ColumnHeaderViewModel(title: room?.name ?? "unknown",
									 subtitle: location?.name ?? "unknown",
									 color: color)
	}
	
	static func viewModel(employee: Employee?,
						  location: Location?) -> ColumnHeaderViewModel {
		let color = location?.color != nil ? UIColor.fromHex(location!.color) : UIColor.clear
		return ColumnHeaderViewModel(title: employee?.name ?? "unknown",
									 subtitle: location?.name ?? "unknown",
									 color: color)
	}
}
