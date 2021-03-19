import Model
import Util
import SwiftUI
import Avatar

struct JourneyAvatarView: View {
	let journey: Journey
	let font: Font
	let bgColor: Color
	var body: some View {
		AvatarView(avatarUrl: journey.first?.clientPhoto ?? "",
				   initials: journey.first?.employeeInitials ?? "",
				   font: font,
				   bgColor: bgColor)
	}
}
