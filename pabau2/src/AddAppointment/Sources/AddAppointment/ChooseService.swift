import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents
import CoreDataModel

let chooseServiceReducer =
    Reducer<ChooseServiceState, ChooseServiceAction, AddAppointmentEnv> { state, action, env in
        switch action {
        case .onAppear:
            state.searchText = ""
            return env.repository.getServices()
                .catchToEffect()
                .map(ChooseServiceAction.gotServiceResponse)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        case .gotServiceResponse(let result):
            switch result {
            case .success(let response):
                state.groupedServices = [String: [Service]].init(
                    grouping: response.state, by: { $0.categoryName ?? "No Name" }
                )
            case .failure:
                break
			}
		case .didSelectFilter(let filter):
			state.filterChosen = filter
		case .didSelectService(let service):
			state.chosenService = service
			state.isChooseServiceActive = false
		case .didTapBackBtn:
			state.isChooseServiceActive = false
		case .onSearch(let text):
			state.searchText = text
			if state.searchText.isEmpty {
				break
			}
			state.filteredServices =
				state.groupedServices.flatMap {
					$0.value
				}.filter { $0.name.lowercased().contains(state.searchText.lowercased()) }
		}
        return .none
    }

public enum ChooseServiceFilter: Int, CaseIterable, CustomStringConvertible {
    case allStaff
    case onlyMe

    public var description: String {
        switch self {
        case .allStaff:
            return "All Staff"
        case .onlyMe:
            return "Only Me"
        }
    }
}

public struct ChooseServiceState: Equatable {
    var groupedServices: [String: [Service]] = [:]
	var filteredServices: [Service] = []
    var isChooseServiceActive: Bool
    var chosenService: Service?
    var filterChosen: ChooseServiceFilter
    var searchText: String = ""
}

public enum ChooseServiceAction: Equatable {
    case onAppear
    case gotServiceResponse(Result<SuccessState<[Service]>, RequestError>)
    case didSelectService(Service)
    case didSelectFilter(ChooseServiceFilter)
    case didTapBackBtn
    case onSearch(String)
}

struct ChooseService: View {
    let store: Store<ChooseServiceState, ChooseServiceAction>
    @ObservedObject var viewStore: ViewStore<ChooseServiceState, ChooseServiceAction>
    init (store: Store<ChooseServiceState, ChooseServiceAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }

    var body: some View {
        VStack {
            HStack {
                SearchView(
                    placeholder: "Search",
                    text: viewStore.binding(
                        get: \.searchText,
                        send: ChooseServiceAction.onSearch)
                )
                .padding(.leading, 60)
                StaffFilterPicker()
                    .padding(.trailing, 60)
			}
			List {
				if viewStore.searchText.isEmpty {
					ForEach(Array(self.viewStore.state.groupedServices.keys), id: \.self) { (key: String) in
						Section(
							header: TextHeader(name: key)
						) {
							ForEach(self.viewStore.state.groupedServices[key]!, id: \.self) { (service: Service) in
								ServiceRow(service: service).onTapGesture {
									self.viewStore.send(.didSelectService(service))
								}
							}.listRowInsets(EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 60))
						}
						.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
						.background(Color.white)
					}
				} else {
					ForEach(viewStore.filteredServices, id: \.self) { (service: Service) in
						ServiceRow(service: service).onTapGesture {
							self.viewStore.send(.didSelectService(service))
						}
					}.listRowInsets(EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 60))
				}
			}
			Spacer()
		}.onAppear {
			self.viewStore.send(.onAppear)
        }
        .padding(0)
        .navigationBarTitle("Services")
        .customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
    }
}

struct ServiceRow: View {
    let service: Service
    var body: some View {
        ColorCircleRow(
            title: service.name,
            subtitle: service.duration ?? "Not set",
            color: Color(hex: service.color ?? "#ffffff"))
    }
}

struct TextHeader: View {
    let name: String
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            Text(name)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 60)
            Divider()
        }.padding(0)
    }
}
