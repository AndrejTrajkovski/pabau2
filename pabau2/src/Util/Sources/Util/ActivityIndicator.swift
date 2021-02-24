import SwiftUI
#if !os(macOS)
public struct ActivityIndicator: UIViewRepresentable {
	public init(isAnimating: Binding<Bool>,
				style: UIActivityIndicatorView.Style) {
		self._isAnimating = isAnimating
		self.style = style
	}
	
	@Binding var isAnimating: Bool
	let style: UIActivityIndicatorView.Style
	
	public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
		return UIActivityIndicatorView(style: style)
	}
	
	public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
		isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
	}
}
#endif
