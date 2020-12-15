import SwiftUI
import Util

struct PagerView<Content: View>: View {
	let pageCount: Int
	@Binding var currentIndex: Int
	let content: Content

	@GestureState private var translation: CGFloat = 0

	init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
		self.pageCount = pageCount
		self._currentIndex = currentIndex
		self.content = content()
	}

	var body: some View {
		GeometryReaderPatch { geometry in
			HStack(spacing: 0) {
				self.content.frame(width: geometry.size.width)
			}
			.frame(width: geometry.size.width, alignment: .leading)
			.offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
			.offset(x: self.translation)
			.animation(.default)
			.gesture(
				DragGesture().updating(self.$translation) { value, state, _ in
					state = value.translation.width
				}.onEnded { value in
					let offset = value.translation.width / geometry.size.width
					print(offset)
					let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
					print(newIndex)
					self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
					print(self.currentIndex)
				}
			)
		}
	}
}
