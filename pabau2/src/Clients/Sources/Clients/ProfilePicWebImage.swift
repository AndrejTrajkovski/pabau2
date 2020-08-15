import SDWebImageSwiftUI
import SwiftUI

struct ProfilePicWebImage: View {
	let url: String?
	var body: some View {
		WebImage(url: url.flatMap(URL.init(string:)))
			.resizable()
//			.placeholder(Image(systemName: "person.crop.circle.badge.plus"))
			.indicator(.activity) // Activity Indicator
			.transition(.fade(duration: 0.5)) // Fade Transition with duration
			.scaledToFit()
	}
}
