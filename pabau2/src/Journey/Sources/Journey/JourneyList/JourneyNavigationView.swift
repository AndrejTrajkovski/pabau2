import SwiftUI
import ComposableArchitecture
import Util
import Filters

public struct JourneyNavigationView: View {
	let store: Store<JourneyContainerState, JourneyContainerAction>
	@ObservedObject var viewStore: ViewStore<JourneyContainerState, JourneyContainerAction>
//	struct ViewState: Equatable {
//		let isShowingEmployees: Bool
//		init(state: JourneyContainerState) {
//			self.isShowingEmployees = state.journey.isShowingEmployeesFilter
//		}
//	}
	public init(_ store: Store<JourneyContainerState, JourneyContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	public var body: some View {
		print("JourneyNavigationView")
		return ZStack(alignment: .topTrailing) {
			NavigationView {
				JourneyContainerView(store.scope(state: { $0 },
												 action: { $0 }))
			}
			.navigationViewStyle(StackNavigationViewStyle())
			if self.viewStore.state.journey.isShowingEmployeesFilter {
				journeyFilter()
			}
		}
	}
	
	fileprivate func journeyFilter() -> some View {
		IfLetStore(store.scope(state: { $0.journeyEmployeesFilter },
						action: { .employeesFilter($0) }),
				   then: { filterStore in
					JourneyFilter.init(filterStore)
						.transition(.moveAndFade)
				   }
		)
	}
}
