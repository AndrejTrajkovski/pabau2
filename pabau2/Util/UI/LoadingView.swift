import SwiftUI

struct LoadingView<Content>: View where Content: View {

	let title: String
	@Binding var isShowing: Bool
	var content: () -> Content

	var body: some View {
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
