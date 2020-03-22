import SwiftUI

public extension View {
	func loadingView(_ isShowing: Binding<Bool>,
									 _ title: String = "Loading") -> some View {
		self.modifier(LoadingViewModifier(title: title, isShowing: isShowing))
	}
}

public struct LoadingViewModifier: ViewModifier {
	let title: String
	@Binding var isShowing: Bool
	public func body(content: Content) -> some View {
		LoadingView(title: title,
								bindingIsShowing: $isShowing,
								content: { content })
	}
}

public struct LoadingView<Content>: View where Content: View {
	public init(title: String, bindingIsShowing: Binding<Bool>, content: @escaping () -> Content) {
		self.title = title
		self._isShowing = bindingIsShowing
		self.content = content
	}

	let title: String
	@Binding var isShowing: Bool
	var content: () -> Content

	public var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				self.content()
					.disabled(self.isShowing)
					.blur(radius: self.isShowing ? 3 : 0)
				VStack {
					Text(self.title)
					ActivityIndicator(isAnimating: .constant(true), style: .large)
				}
				.frame(width: geometry.size.width / 2,
							 height: geometry.size.height / 5)
					.background(Color.white)
					.foregroundColor(Color.blue)
					.cornerRadius(20)
					.opacity(self.isShowing ? 1 : 0)
			}
		}
	}
}
