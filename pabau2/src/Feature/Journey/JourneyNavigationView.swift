import SwiftUI
import ComposableArchitecture
import Util

public struct JourneyNavigationView: View {
	let store: Store<JourneyState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, JourneyContainerAction>
	struct ViewState: Equatable {
		let isJourneyModalShown: Bool
		init(state: JourneyState) {
			self.isJourneyModalShown = state.isJourneyModalShown
		}
	}
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: ViewState.init(state:),
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
		.modalLink(isPresented: .constant(self.viewStore.value.isJourneyModalShown),
							 linkType: ModalTransition.circleReveal,
							 destination: {
								CheckIn()
		})
	}
}
