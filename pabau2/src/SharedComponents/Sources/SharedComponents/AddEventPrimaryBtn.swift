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
		VStack {
			Spacer().frame(height: 40)
			PrimaryButton(title, action).frame(width: 315, height: 52)
		}
	}
}
