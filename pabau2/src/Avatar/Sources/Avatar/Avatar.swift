import SwiftUI
import SDWebImageSwiftUI

public struct AvatarView: View {

	public init(
		avatarUrl: String?,
		initials: String?,
		font: Font,
		bgColor: Color
	) {
		self.avatarUrl = avatarUrl
		self.initials = initials ?? ""
		self.font = font
		self.bgColor = bgColor
	}

	let avatarUrl: String?
	let initials: String
	let font: Font
	let bgColor: Color

	var baseUrl: String {
		return "https://ios.pabau.me/"
	}

	public var body: some View {
		CircleFrame(bgColor) {
			Group {
				if avatarUrl != nil {
					WebImage(url: URL(string: avatarUrl!))
                        .resizable()
						.indicator(.activity) // Activity Indicator
                        .scaledToFill()
						.clipShape(Circle())
				} else {
					Text(initials.uppercased())
						.font(font)
						.foregroundColor(.white)
				}
			}
		}
	}
}

public struct CircleFrame<Content: View>: View {

	public init(_ bgColor: Color = .accentColor, _ content: @escaping () -> Content) {
		self.bgColor = bgColor
		self.content = content
	}

	let bgColor: Color
	let content: () -> Content

	public var body: some View {
		Circle()
			.fill(bgColor)
			.overlay(
				ZStack {
					content()
				}
		)
	}
}
