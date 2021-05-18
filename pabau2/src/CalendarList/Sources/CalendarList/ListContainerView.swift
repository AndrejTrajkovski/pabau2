import SwiftUI
import Model
import Util
import ComposableArchitecture
import SwiftDate
import CasePaths
import Overture
import SharedComponents
import Appointments
import Combine

public typealias ListCalendarEnvironment = (
	journeyAPI: JourneyAPI,
	clientsAPI: ClientsAPI,
	userDefaults: UserDefaultsConfig
)

let listCalendarReducer: Reducer<ListState, ListAction, ListCalendarEnvironment> =
	.combine (
		.init { state, action, environment in
            struct SearchJourneyId: Hashable {}

			switch action {
			
			case .selectedFilter(let filter):
				state.selectedFilter = filter
				
			case .searchedText(let searchText):
				state.searchText = searchText
				
			case .locationSection(id: _, action: _):
				break
			}
			return .none
	}
)

public struct ListContainerView: View {
	
	let store: Store<ListContainerState, ListAction>
	@ObservedObject var viewStore: ViewStore<ViewState, ListAction>

    @State var showSearchBar: Bool = false
	
	struct ViewState: Equatable {
		let listedAppointments: [Appointment]
		let isLoadingApps: Bool
        let searchQuery: String
		init(state: ListContainerState) {
			self.listedAppointments = []
            self.searchQuery = state.list.searchText
			self.isLoadingApps = state.appsLoadingState.isLoading
			UITableView.appearance().separatorStyle = .none
		}
	}
	
	public init(store: Store<ListContainerState, ListAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: ViewState.init(state:),
						 action: { $0 }))
	}
	
	public var body: some View {
		VStack {

            FilterPicker()

            if self.showSearchBar {
                searchBar
            }
			
			ScrollView {
				LazyVStack {
					ForEachStore(store.scope(state: { $0.locationSections },
											 action: ListAction.locationSection(id:action:)), content: LocationSection.init(store:)
					)
				}
			}
//            JourneyList(self.viewStore.state.listedAppointments) {
//                self.viewStore.send(.selectedAppointment($0))
//            }.loadingView(.constant(self.viewStore.state.isLoadingApps),
//						  Texts.fetchingJourneys)
			
            Spacer()
        }
    }
	
	var searchBar: some View {
		SearchView(
			placeholder: "Search",
			text: viewStore.binding(
				get: \.searchQuery,
				send: { ListAction.searchedText($0) }
			)
		)
		.isHidden(!self.showSearchBar)
		.padding([.leading, .trailing], 16)
	}
}

struct LocationSectionState: Equatable, Identifiable {
	var location: Location
	var appointments: IdentifiedArrayOf<Appointment>
	var id: Location.ID { location.id }
}

struct LocationSection: View {
	let store: Store<LocationSectionState, LocationSectionAction>
	@ObservedObject var viewStore: ViewStore<String, Never>
	
	init(store: Store<LocationSectionState, LocationSectionAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: { $0.location.name }).actionless)
	}
	
	var body: some View {
		Section.init(header:
						Text(viewStore.state)
						.padding(.leading, 16)
						.font(.semibold20)
						.frame(maxWidth: .infinity, alignment: .leading)
		,
		content: {
			Divider()
			ForEachStore(store.scope(state: { $0.appointments },
									 action: LocationSectionAction.rows(id:action:)),
						 content: ListCellStoreRow.init(store:)
			)
		})
	}
}

struct ListCellStoreRow: View {
	let store: Store<Appointment, ListRowAction>
	
	var body: some View {
		WithViewStore(store) { viewStore in
			ListCell(appointment: viewStore.state)
//				.contextMenu {
//					ListCellContextMenu()
//				}
				.onTapGesture { viewStore.send(.select) }
				.listRowInsets(EdgeInsets())
		}
	}
}

struct FilterPicker: View {
	@State private var filter: CompleteFilter = .all
	var body: some View {
		VStack {
			Picker(selection: $filter, label: Text("Filter")) {
				ForEach(CompleteFilter.allCases, id: \.self) { (filter: CompleteFilter) in
					Text(String(filter.description)).tag(filter.rawValue)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}.padding()
	}
}
