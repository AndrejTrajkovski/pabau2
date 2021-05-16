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
			
			case .selectedAppointment:
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
		let isLoadingJourneys: Bool
        let searchQuery: String
		init(state: ListContainerState) {
			self.listedAppointments = state.appointments.appointments[state.selectedDate]?.elements ?? []
            self.searchQuery = state.journey.searchText
			self.isLoadingJourneys = state.loadingState.isLoading
			UITableView.appearance().separatorStyle = .none
		}
	}
	
	public init(_ store: Store<ListContainerState, ListAction>) {
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

            JourneyList(self.viewStore.state.listedAppointments) {
                self.viewStore.send(.selectedAppointment($0))
            }.loadingView(.constant(self.viewStore.state.isLoadingJourneys),
						  Texts.fetchingJourneys)
			
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

struct JourneyList: View {
	let appointments: [Appointment]
	let onSelect: (Appointment) -> Void
	init (_ appointments: [Appointment],
				_ onSelect: @escaping (Appointment) -> Void) {
		self.appointments = appointments
		self.onSelect = onSelect
	}
	var body: some View {
		List {
			ForEach(appointments.indices) { idx in
				ListCell.init(appointment: appointments[idx])
					.contextMenu {
						ListCellContextMenu()
					}
					.onTapGesture { self.onSelect(appointments[idx]) }
					.listRowInsets(EdgeInsets())
			}
        }.id(UUID())
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
