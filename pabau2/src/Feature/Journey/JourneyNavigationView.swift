import SwiftUI
import ComposableArchitecture

public struct JourneyNavigationView: View {
	let store: Store<JourneyState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<JourneyState>
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	public var body: some View {
		NavigationView {
			JourneyContainerView(self.store.scope(value: { $0 },
																					 action: { $0 }))
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
