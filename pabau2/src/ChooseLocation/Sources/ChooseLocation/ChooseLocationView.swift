import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

public struct ChooseLocationView: View {
    let store: Store<ChooseLocationState, ChooseLocationAction>
    @ObservedObject var viewStore: ViewStore<ChooseLocationState, ChooseLocationAction>

    public init(store: Store<ChooseLocationState, ChooseLocationAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }

    public var body: some View {
		VStack {
			HStack {
				SearchView(
					placeholder: "Search",
					text: viewStore.binding(
						get: \.searchText,
						send: ChooseLocationAction.onSearch)
				)
				
				ReloadButton(onReload: { viewStore.send(.reload) })
			}
			
			switch viewStore.locationsLS {
			case .initial, .gotSuccess:
				List {
					ForEach(self.viewStore.state.filteredLocations, id: \.id) { location in
						TextAndCheckMark(
							location.name,
							location.id == self.viewStore.state.chosenLocationId
						).onTapGesture {
							self.viewStore.send(.didSelectLocation(location.id))
						}
					}
				}
			case .loading:
				LoadingSpinner()
			case .gotError(_):
				Text("Error loading locations.")
			}
        }
        .padding()
        .navigationBarTitle("Locations")
        .customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
    }
}
