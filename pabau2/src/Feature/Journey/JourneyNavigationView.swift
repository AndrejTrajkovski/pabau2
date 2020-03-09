import SwiftUI

public struct JourneyNavigationView: View {
	public init () {}
	public var body: some View {
		NavigationView {
			JourneyContainerView()
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

					}, label: {
						Image(systemName: "person")
							.font(.system(size: 20))
					})
			)
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}
