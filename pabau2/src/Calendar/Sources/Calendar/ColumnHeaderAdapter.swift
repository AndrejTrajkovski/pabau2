import Model
import ComposableArchitecture
import UIKit

enum ColumnHeaderAdapter {
	
	static func makeViewModel(_ firstSectionApp: AppointmentEvent,
					   _ calType: CalendarType,
					   _ locations: [Location.Id: Location],
					   _ rooms: [Room.Id: Room],
					   _ employees: [Employee.Id: Employee]) -> ColumnHeaderViewModel {
		if calType == .room {
			let room = rooms[firstSectionApp.app.roomId]
			let location = room.flatMap { locations[$0.locationId] }
			return viewModel(room: room, location: location)
		} else if calType == .employee {
			let employee = employees[firstSectionApp.app.employeeId]
			let location = employee.flatMap { locations[$0.locationId] }
			return viewModel(employee: employee, location: location)
		}
		fatalError("implement day view in switch")
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
