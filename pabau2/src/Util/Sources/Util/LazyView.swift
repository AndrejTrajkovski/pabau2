import SwiftUI
#if !os(macOS)
public struct LazyView<Content: View>: View {
	let build: () -> Content
	public init(_ build: @autoclosure @escaping () -> Content) {
		self.build = build
	}
	public var body: Content {
		build()
	}
}
#endif
