import SwiftUI

public extension View {
	func wrapAsSection(title: String) -> some View {
		self.modifier(SectionModifier(title: title))
	}
}

struct SectionModifier: ViewModifier {

	let title: String

	func body(content: Content) -> some View {
		VStack(spacing: 24) {
			SectionTitle(title: title)
			content
		}.padding([.bottom, .top], 24)
	}
}
