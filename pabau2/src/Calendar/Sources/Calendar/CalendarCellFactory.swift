import Foundation
import UIKit
import SwiftUI
import JZCalendarWeekView

struct CellConfigurator {
	
	func configure(
		cell: inout BaseCalendarCell,
		appointment: AppointmentEvent
		) {
		configure(cell: &cell,
							patientName: appointment.patient,
							serviceName: appointment.service,
							serviceColor: appointment.color,
							roomName: "",
							event: appointment)
	}
	
	func configure(
		cell: inout BaseCalendarCell,
		patientName: String?,
		serviceName: String,
		serviceColor: String?,
		roomName: String?,
		event: JZBaseEvent
		) {
		cell.title.text = patientName ?? "TODO: parse bookout"
		let roomString = roomName != nil ? (" " + roomName!) : ""
		cell.subtitle.text = serviceName + roomString
		let serviceColor = serviceColor != nil ? UIColor().fromHex(serviceColor!) : UIColor.clear
		cell.colorBlock.backgroundColor = serviceColor
		cell.contentView.backgroundColor = serviceColor.lighter(by: 0.9)
		cell.event = event
	}
}
