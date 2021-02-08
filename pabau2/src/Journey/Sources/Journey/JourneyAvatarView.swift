import Model
import Util
import SwiftUI

struct JourneyAvatarView: View {
	let journey: Journey
	let font: Font
	let bgColor: Color
	var body: some View {
		AvatarView(avatarUrl: journey.first!.customerPhoto,
				   initials: journey.first!.customerName?.split(separator: " ").compactMap(\.first).map(String.init(_:)).joined().uppercased() ?? "",
							 font: font,
							 bgColor: bgColor)
	}
}
