import SwiftUI

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
	public var body: some View {
		Circle()
			.fill(bgColor)
			.overlay(
				ZStack {
					Group {
						if avatarUrl != nil {
							Image("\(avatarUrl!)")
								.resizable()
								.aspectRatio(contentMode: .fill)
								.clipShape(Circle())
						} else {
							Text(initials.uppercased())
								.font(font)
								.foregroundColor(.white)
						}
					}
				}
		)
	}
}
