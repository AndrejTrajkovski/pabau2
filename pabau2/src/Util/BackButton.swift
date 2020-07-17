import SwiftUI

public struct MyBackButton: View {
	let action: () -> Void
	
	public init(action: @escaping () -> Void) {
		self.action = action
	}
	
	public var body: some View {
		Button(action: {
			self.action()
		}, label: {
			Image(systemName: "chevron.left")
				.font(Font.title.weight(.semibold))
			Text("Back")
		})
	}
}

struct BackButton: ViewModifier {
	let action: () -> Void
	func body(content: Content) -> some View {
		content
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading:
				MyBackButton(action: action)
		)
	}
}
extension View {
	public func customBackButton(action: @escaping () -> Void) -> some View {
		self.modifier(BackButton(action: action))
	}
}
