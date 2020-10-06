import SwiftUI
import ComposableArchitecture
import Util

public struct JourneyNavigationView: View {
	let store: Store<JourneyContainerState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, JourneyContainerAction>
	struct ViewState: Equatable { init() {} }
	public init(_ store: Store<JourneyContainerState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store
			.scope(state: {_ in ViewState()},
						 action: { $0 }))
	}
	public var body: some View {
		NavigationView {
			JourneyContainerView(self.store.scope(state: { $0 },
																					action: { $0 }))
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
