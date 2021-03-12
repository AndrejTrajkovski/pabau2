import SwiftUI
import ComposableArchitecture
import Util
import Model

public struct ChooseLocationState: Equatable {
    public var isChooseLocationActive: Bool
    public var locations: IdentifiedArrayOf<Location> = []
    public var filteredLocations: IdentifiedArrayOf<Location> = []
    public var chosenLocation: Location?
    public var searchText: String = "" {
        didSet {
            isSearching = !searchText.isEmpty
        }
    }
    public var isSearching = false

    public init(isChooseLocationActive: Bool) {
        self.isChooseLocationActive = isChooseLocationActive
    }
}

public enum ChooseLocationAction: Equatable {
    case onAppear
    case gotLocationsResponse(Result<[Location], RequestError>)
    case didSelectLocation(Location)
    case onSearch(String)
    case didTapBackBtn
}

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
            SearchView(
                placeholder: "Search",
                text: viewStore.binding(
                    get: \.searchText,
                    send: ChooseLocationAction.onSearch)
            )
            List {
                ForEach(self.viewStore.state.filteredLocations, id: \.id) { employee in
                    TextAndCheckMark(
                        employee.name,
                        employee.id == self.viewStore.state.chosenLocation?.id
                    ).onTapGesture {
                        self.viewStore.send(.didSelectLocation(employee))
                    }
                }
            }
        }
        .onAppear {
            self.viewStore.send(.onAppear)
        }
        .padding()
        .navigationBarTitle("Locations")
        .customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
    }
}
