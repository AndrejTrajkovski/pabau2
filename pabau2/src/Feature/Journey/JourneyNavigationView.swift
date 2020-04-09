import SwiftUI
import ComposableArchitecture
import Util

public struct JourneyNavigationView: View {
	let store: Store<JourneyState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, JourneyContainerAction>
	struct ViewState: Equatable { init() {} }
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: {_ in ViewState()},
						 action: { $0 })
			.view
		print("JourneyNavigationView init")
	}
	public var body: some View {
		print("JourneyNavigationView body")
		return NavigationView {
			JourneyContainerView(self.store.scope(value: { $0 },
																					 action: { $0 }))
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
