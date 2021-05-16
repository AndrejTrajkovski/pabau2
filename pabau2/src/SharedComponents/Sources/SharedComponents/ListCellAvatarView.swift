import Model
import Util
import SwiftUI
import Avatar

public struct ListCellAvatarView: View {
	
	public init(appointment: Appointment, font: Font, bgColor: Color) {
		self.appointment = appointment
		self.font = font
		self.bgColor = bgColor
	}
	
	let appointment: Appointment
	let font: Font
	let bgColor: Color
	public var body: some View {
		AvatarView(avatarUrl: appointment.clientPhoto,
				   initials: appointment.employeeInitials,
				   font: font,
				   bgColor: bgColor)
	}
}
