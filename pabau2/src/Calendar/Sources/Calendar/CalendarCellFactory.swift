import Foundation
import UIKit

struct CalendarCellFactory {
	func configure(
		cell: inout BaseCalendarCell,
		patientName: String,
		serviceName: String,
		serviceColor: UIColor,
		lighterServiceColor: UIColor,
		roomName: String?
		) {
		cell.title.text = patientName
		let roomString = roomName != nil ? (" " + roomName!) : ""
		cell.subtitle.text = serviceName + roomString
		cell.colorBlock.backgroundColor = serviceColor
		cell.contentView.backgroundColor = lighterServiceColor
	}
}
