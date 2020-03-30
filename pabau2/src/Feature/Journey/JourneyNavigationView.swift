import SwiftUI
import ComposableArchitecture
import Util

public struct JourneyNavigationView: View {
	let store: Store<JourneyState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<JourneyState, JourneyContainerAction>
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = self.store.view
		print("JourneyNavigationView init")
	}
	public var body: some View {
		print("JourneyNavigationView body")
		return NavigationView {
			JourneyContainerView(self.store.scope(value: { $0 },
																					 action: { $0 }))
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.modalLink(isPresented: .constant(self.viewStore.value.isJourneyModalShown),
							 linkType: ModalTransition.circleReveal,
							 destination: {
								CheckIn()
		})
	}
}
