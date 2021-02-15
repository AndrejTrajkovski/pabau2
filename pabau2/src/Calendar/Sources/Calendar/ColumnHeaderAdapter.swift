import Model
import ComposableArchitecture
import UIKit

enum ColumnHeaderAdapter {

	static func weekViewModel(_ startOfDay: Date) -> ColumnHeaderViewModel {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		let date = formatter.string(from: startOfDay)
		formatter.dateFormat = "EEEE"
		let dayOfWeek = formatter.string(from: startOfDay)
		return ColumnHeaderViewModel(title: date, subtitle: dayOfWeek, color: UIColor.clear)
	}

	static func sectionViewModel(_ section: Any,
								 _ location: Location) -> ColumnHeaderViewModel? {
		if let room = section as? Room {
			return viewModel(room: room, location: location)
		} else if let employee = section as? Employee {
			return viewModel(employee: employee, location: location)
		}
		return nil
	}

	static func viewModel(room: Room?,
						  location: Location?) -> ColumnHeaderViewModel {
		let color = location?.color != nil ? UIColor.fromHex(location?.color ?? "") : UIColor.clear
		return ColumnHeaderViewModel(title: room?.name ?? "unknown",
									 subtitle: location?.name ?? "unknown",
									 color: color)
	}

	static func viewModel(employee: Employee?,
						  location: Location?) -> ColumnHeaderViewModel {
		let color = location?.color != nil ? UIColor.fromHex(location?.color ?? "") : UIColor.clear
		return ColumnHeaderViewModel(title: employee?.name ?? "unknown",
									 subtitle: location?.name ?? "unknown",
									 color: color)
	}
}
