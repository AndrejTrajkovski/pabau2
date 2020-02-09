import SwiftUI

struct BackButton: ViewModifier {
	let action: () -> Void
	func body(content: Content) -> some View {
		content
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading:
				Button(action: {
					self.action()
				}, label: {
					Image(systemName: "chevron.left")
						.font(Font.title.weight(.semibold))
					Text("Back")
				})
		)
	}
}
extension View {
	func customBackButton(action: @escaping () -> Void) -> some View {
		self.modifier(BackButton(action: action))
	}
}
