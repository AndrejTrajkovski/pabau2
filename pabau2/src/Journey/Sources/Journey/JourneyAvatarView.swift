import Model
import Util
import SwiftUI

struct JourneyAvatarView: View {
	let journey: Journey
	let font: Font
	let bgColor: Color
	var body: some View {
		AvatarView(avatarUrl: journey.clientPhoto,
							 initials: journey.initials,
							 font: font,
							 bgColor: bgColor)
	}
}
