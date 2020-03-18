import SwiftUI
import ComposableArchitecture

public struct JourneyNavigationView: View {
	@ObservedObject var store: Store<JourneyState, JourneyContainerAction>
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
	}
	public var body: some View {
		NavigationView {
			JourneyContainerView(self.store.view(value: { $0 },
																					 action: { .journey($0) }))
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
