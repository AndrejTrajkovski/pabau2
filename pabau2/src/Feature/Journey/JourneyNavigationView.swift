import SwiftUI
import ComposableArchitecture

public struct JourneyNavigationView: View {
	@ObservedObject var store: Store<JourneyState, JourneyContainerAction>
	public init(_ store: Store<JourneyState, JourneyContainerAction>) {
		self.store = store
	}
	public var body: some View {
		ZStack(alignment: .topTrailing) {
			NavigationView {
				JourneyContainerView(self.store.view(value: { $0 },
																						 action: { .journey($0) }))
			}
			.navigationViewStyle(StackNavigationViewStyle())
			EmployeesListStore(self.store.view(value: { $0.employeesState } ,
																				 action: { .employees($0)}))
				.frame(width: self.store.value.employeesState.isShowingEmployees ? 200 : 0)
		}
	}
}
