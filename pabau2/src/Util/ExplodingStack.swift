import SwiftUI

public extension View {
	func exploding(_ alignment: Alignment) -> some View {
		self.modifier(ExplodingElement(alignment: alignment))
	}
}

struct ExplodingElement: ViewModifier {
	let alignment: Alignment
	func body(content: Content) -> some View {
		ExplodingFrame({content}, alignment)
	}
}

struct ExplodingFrame<Content: View>: View {
	let content: () -> Content
	let alignment: Alignment
	init(@ViewBuilder _ content: @escaping () -> Content,
										_ alignment: Alignment) {
		self.content = content
		self.alignment = alignment
	}

	var body: some View {
		content().frame(minWidth: 0, maxWidth: .infinity,
										minHeight: 0, maxHeight: .infinity,
										alignment: alignment)
	}
}
