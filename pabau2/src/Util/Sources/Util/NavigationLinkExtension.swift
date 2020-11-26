import SwiftUI
#if !os(macOS)
extension NavigationLink where Label == EmptyView {
	public static func emptyHidden(_ isActive: Bool,
								   _ destination: Destination) -> some View {
		NavigationLink.init(destination: destination,
							isActive: .constant(isActive),
							label: { EmptyView() }).hidden()
	}
}
#endif
