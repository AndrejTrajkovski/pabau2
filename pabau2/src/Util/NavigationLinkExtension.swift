import SwiftUI

extension NavigationLink where Label == EmptyView {
	public static func emptyHidden(destination: Destination,
																 isActive: Bool) -> some View {
		NavigationLink.init(destination: destination,
												isActive: .constant(isActive),
												label: { EmptyView() }).hidden()
	}
}
