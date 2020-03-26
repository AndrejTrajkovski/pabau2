import SwiftUI
import Model
import ComposableArchitecture

func chooseServiceReducer(state: inout ChooseServiceState,
													action: ChooseServiceAction,
													environment: JourneyEnvironemnt) -> [Effect<ChooseServiceAction>] {
	switch action {
	case .didSelectFilter(let filter):
		state.filterChosen = filter
	case .didSelectServiceId(let serviceID):
		state.chosenServiceId = serviceID
		state.isChooseServiceActive = false
	case .didTapBackBtn:
		state.isChooseServiceActive = false
	}
	return []
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
	var isChooseServiceActive: Bool
	var chosenServiceId: Int
	var filterChosen: ChooseServiceFilter

	var chosenServiceName: String {
		self.services.first(where: { $0.id == chosenServiceId })?.name ?? ""
	}

	let services: [Service] = [
		Service.init(id: 0, name: "Service 1", color: "#eb4034", categoryId: 1, categoryName: "Injectables"),
		Service.init(id: 1, name: "Service 2", color: "#34eba5", categoryId: 2, categoryName: "Mosaic"),
		Service.init(id: 2, name: "Service 3", color: "#34eba5", categoryId: 2, categoryName: "Mosaic"),
		Service.init(id: 3, name: "Service 4", color: "#34eba5", categoryId: 2, categoryName: "Mosaic"),
		Service.init(id: 4, name: "Service 5", color: "#eb34b1", categoryId: 3, categoryName: "Urethra"),
		Service.init(id: 5, name: "Service 6", color: "#eb34b1", categoryId: 3, categoryName: "Urethra"),
		Service.init(id: 6, name: "Service 7", color: "#eb34b1", categoryId: 3, categoryName: "Urethra")
	]
}

public enum ChooseServiceAction {
	case didSelectServiceId(Int)
	case didSelectFilter(ChooseServiceFilter)
	case didTapBackBtn
}

struct ChooseService: View {
	let store: Store<ChooseServiceState, ChooseServiceAction>
	@ObservedObject var viewStore: ViewStore<ViewState>
	init (store: Store<ChooseServiceState, ChooseServiceAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: ViewState.init(state:), action: { $0 })
			.view
	}

	struct ViewState: Equatable {
		var groupedServices: [Int: [Service]]
		var listServices: [[Service]] {
			self.groupedServices.map({ $0.value })
		}
	}

	@State var searchText: String = ""
	var body: some View {
		VStack {
			HStack {
				TextField("TODO: search: ", text: self.$searchText)
				StaffFilterPicker()
			}
			List {
				ForEach(self.viewStore.value.listServices, id: \.self.first!.categoryId) { (group: [Service]) in
					Section(header: Text(group.first!.categoryName)) {
						ForEach(group, id: \.self) { (item: Service) in
							Text(item.name)
						}
					}
				}
			}
		}.padding()
	}
}

struct StaffFilterPicker: View {
	@State private var filter: ChooseServiceFilter = .onlyMe
	var body: some View {
		VStack {
			Picker(selection: $filter, label: Text("Filter")) {
				ForEach(ChooseServiceFilter.allCases, id: \.self) { (filter: ChooseServiceFilter) in
					Text(String(filter.description)).tag(filter.rawValue)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}.padding()
	}
}

extension ChooseService.ViewState {
  init(state: ChooseServiceState) {
		self.groupedServices = [Int: [Service]].init(grouping: state.services, by: { $0.categoryId })
	}
}
