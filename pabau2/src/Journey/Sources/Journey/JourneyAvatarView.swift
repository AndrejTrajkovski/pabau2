import Model
import Util
import SwiftUI
import Avatar

struct JourneyAvatarView: View {
	let journey: Journey
	let font: Font
	let bgColor: Color
	var body: some View {
		AvatarView(avatarUrl: journey.clientPhoto ?? "",
				   initials: journey.initials,
				   font: font,
				   bgColor: bgColor)
	}
}
