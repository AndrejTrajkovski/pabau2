import SwiftUI
import Util

public struct AddEventPrimaryBtn: View {
	public init(title: String, action: @escaping () -> Void) {
		self.title = title
		self.action = action
	}

	let title: String
	let action: () -> Void

	public var body: some View {
		GeometryReader { geometry in
            PrimaryButton(title, action)
                .frame(width: min(geometry.size.width * 0.8, 495), height: 60)
                .position(x: geometry.size.width * 0.5)
		}
	}
}
