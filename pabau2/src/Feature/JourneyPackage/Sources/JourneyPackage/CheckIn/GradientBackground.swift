import SwiftUI

struct GradientBackground<Content: View>: View {
	let content: () -> Content
	init(@ViewBuilder _ content: @escaping () -> Content) {
		self.content = content
	}

	var body: some View {
		ZStack {
			Rectangle().fill(
				LinearGradient(gradient: .init(colors: [.checkInGradient1, .deepSkyBlue]), startPoint: .top, endPoint: .bottom)
			)
			content()
		}
	}
}

struct GradientModifiler: ViewModifier {
	func body(content: Content) -> some View {
		GradientBackground { content }
	}
}

extension View {
	func gradientView() -> some View {
		self.modifier(GradientModifiler())
	}
}
