import SwiftUI

public struct NumberEclipse: View {
	let text: String

	public init(text: String) {
		self.text = text
	}

	public var body: some View {
		Text(text)
			.foregroundColor(.white)
			.font(.semibold14)
			.padding(5)
			.frame(width: 50, height: 20)
			.background(RoundedCorners(color: .blue, tl: 25, tr: 25, bl: 25, br: 25))
	}
}
