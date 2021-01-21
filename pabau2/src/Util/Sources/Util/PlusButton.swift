import SwiftUI

public struct PlusButton: View {
	let action: () -> Void

	public init (_ action: @escaping () -> Void) {
		self.action = action
	}

	public var body: some View {
		Button(action: action, label: {
			Image(systemName: "plus")
				.font(.system(size: 20))
				.frame(width: 44, height: 44)
		})
	}
}
