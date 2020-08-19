import SwiftUI

public struct ListFrame<Content: View>: View {
	public init(style: ListFrameStyle,
			 @ViewBuilder _ content: @escaping () -> Content) {
		self.style = style
		self.content = content
	}

	let style: ListFrameStyle
	let content: () -> Content

	public var body: some View {
		VStack(spacing: 0) {
			Rectangle().fill(style.btnColor).frame(height: 8)
			content()
				.padding(32)
				.background(style.bgColor)
		}
	}
}
