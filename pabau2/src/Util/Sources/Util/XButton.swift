import SwiftUI

public struct XButton: View {

	public init(onTouch: @escaping () -> Void) {
		self.onTouch = onTouch
	}

	public let onTouch: () -> Void
	public var body: some View {
		Button.init(action: onTouch, label: {
			Image(systemName: "xmark")
				.font(Font.light30)
				.foregroundColor(.gray142)
				.frame(width: 30, height: 30)
		})
	}
}
