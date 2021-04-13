import Model
import Util
import SwiftUI
import Avatar

struct JourneyAvatarView: View {
	let appointment: Appointment
	let font: Font
	let bgColor: Color
	var body: some View {
		AvatarView(avatarUrl: appointment.clientPhoto,
				   initials: appointment.employeeInitials,
				   font: font,
				   bgColor: bgColor)
	}
}
