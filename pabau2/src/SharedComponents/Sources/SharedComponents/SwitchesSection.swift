import SwiftUI

public extension View {
	func switchesSection(title: String) -> some View {
		self.modifier(SwitchesSection(title: title))
	}
}

public struct SwitchesSection: ViewModifier {
	let title: String
	public func body(content: Content) -> some View {
		VStack(alignment: .leading, spacing: 8.0) {
			Text(title).font(.semibold24).padding([.top, .bottom])
			content
		}
	}
}
