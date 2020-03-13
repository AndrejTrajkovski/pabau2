import SwiftUI
import ComposableArchitecture
public struct JourneyNavigationView: View {
	@ObservedObject var store: Store<JourneyState, JourneyAction>
	public init(_ store: Store<JourneyState, JourneyAction>) {
		self.store = store
	}
	public var body: some View {
		NavigationView {
			JourneyContainerView(date: store.value.selectedDate)
				.navigationBarTitle("Manchester", displayMode: .inline)
				.navigationBarItems(leading:
					HStack(spacing: 16.0) {
						Button(action: {
							
						}, label: {
							Image(systemName: "plus")
								.font(.system(size: 20))
						})
						Button(action: {
							
						}, label: {
							Image(systemName: "magnifyingglass")
								.font(.system(size: 20))
						})
					}, trailing:
					Button (action: {
						self.store.send(.toggleEmployees)
					}, label: {
						Image(systemName: "person")
							.font(.system(size: 20))
					})
			)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
