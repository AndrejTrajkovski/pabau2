import SwiftUI

public struct ReloadButton: View {
	
	public init(onReload: @escaping () -> Void) {
		self.onReload = onReload
	}
	
	let onReload: () -> Void
	
	public var body: some View {
		Button(action: onReload,
			   label: {
			Image(systemName: "arrow.triangle.2.circlepath")
				.font(.system(size: 24))
		})
	}
}
