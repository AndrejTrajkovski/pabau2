import SwiftUI
#if !os(macOS)
public struct MyBackButton: View {
	let action: () -> Void
	let text: String
	public init(text: String,
							action: @escaping () -> Void) {
		self.action = action
		self.text = text
	}

	public var body: some View {
		Button(action: {
			self.action()
		}, label: {
			Image(systemName: "chevron.left")
				.font(Font.title.weight(.semibold))
			Text(text)
		})
	}
}

struct BackButton: ViewModifier {
	let text: String
    let leadingPadding: CGFloat
	let action: () -> Void
	func body(content: Content) -> some View {
		content
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading:
                MyBackButton(text: text, action: action).padding(.leading, leadingPadding)

		)
	}
}
extension View {
    public func customBackButton(text: String = Texts.back, leadingPadding: CGFloat = 0,
															 action: @escaping () -> Void) -> some View {
		self.modifier(BackButton(text: text, leadingPadding: leadingPadding, action: action))
	}
}
#endif
