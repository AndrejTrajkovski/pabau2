import Foundation
import UIKit
import SwiftUI
import JZCalendarWeekView

struct CellConfigurator {
	
	func configure(
		cell: inout BaseCalendarCell,
		appointment: JZAppointmentEvent
		) {
		switch appointment.app {
		case .appointment(let app):
			configure(cell: &cell,
					  patientName: app.customerName,
					  serviceName: app.service,
					  serviceColor: app.serviceColor,
					  roomName: "",
					  event: appointment)
		case .bookout(let bookout):
			configure(cell: &cell,
					  patientName: bookout.employeeName,
					  serviceName: "Bookout",
					  serviceColor: "000000",
					  roomName: "",
					  event: appointment)
			break
		}
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
		let serviceColor = serviceColor != nil ? UIColor.fromHex(serviceColor!) : UIColor.clear
		cell.colorBlock.backgroundColor = serviceColor
		cell.contentView.backgroundColor = serviceColor.lighter(by: 0.9)
		cell.event = event
	}
}
