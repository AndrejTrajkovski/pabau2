import Model
import Util
import SwiftUI

struct JourneyAvatarView: View {
	let journey: Journey
	let font: Font
	let bgColor: Color
	var body: some View {
		AvatarView(avatarUrl: journey.patient.avatar,
							 initials: journey.patient.initials,
							 font: font,
							 bgColor: bgColor)
	}
}
