import SwiftUI
#if !os(macOS)
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
		GeometryReaderPatch { geometry in
			ZStack(alignment: .center) {
				self.content()
					.disabled(self.isShowing)
					.blur(radius: self.isShowing ? 3 : 0)
				LoadingSpinner(title: self.title)
					.frame(width: geometry.size.width / 2,
						   height: geometry.size.height / 5)
					.background(Color.white)
					.cornerRadius(20)
					.opacity(self.isShowing ? 1 : 0)
			}
		}
	}
}

public struct LoadingSpinner: View {
	
	public init(title: String? = nil) {
		self.title = title
	}
	
	let title: String?
	
	public var body: some View {
		VStack {
			Text(title ?? "Loading...")
			ActivityIndicator(isAnimating: .constant(true), style: .large)
		}
		.foregroundColor(Color.blue)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}

#endif
