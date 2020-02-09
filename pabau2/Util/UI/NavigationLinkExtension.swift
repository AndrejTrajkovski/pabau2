import SwiftUI

extension NavigationLink where Label == EmptyView {
	static func emptyHidden(destination: Destination, isActive: Bool) -> some View {
		return NavigationLink.init(destination: destination,
															 isActive: .constant(isActive),
			label: { EmptyView() }).hidden()
	}
}
