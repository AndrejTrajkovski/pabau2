import SwiftUI
import Model
import ComposableArchitecture
import Util
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
		Service.init(id: 0, name: "Service 1", color: "#eb4034", categoryId: 1, categoryName: "Injectables", duration: "00:45"),
		Service.init(id: 1, name: "Service 2", color: "#34eba5", categoryId: 2, categoryName: "Mosaic"),
		Service.init(id: 2, name: "Service 3", color: "#34eba5", categoryId: 2, categoryName: "Mosaic", duration: "00:30"),
		Service.init(id: 3, name: "Service 4", color: "#34eba5", categoryId: 2, categoryName: "Mosaic", duration: "00:45"),
		Service.init(id: 4, name: "Service 5", color: "#eb34b1", categoryId: 3, categoryName: "Urethra"),
		Service.init(id: 5, name: "Service 6", color: "#eb34b1", categoryId: 3, categoryName: "Urethra", duration: "00:30"),
		Service.init(id: 6, name: "MOS- Scar", color: "#FEC87C", categoryId: 4, categoryName: "MOS", duration: "00:30"),
		Service.init(id: 7, name: "MOS- Acne Scar", color: "#FEC87C", categoryId: 4, categoryName: "MOS", duration: "00:30"),
		Service.init(id: 8, name: "MOS- Skin Tightening", color: "#FEC87C", categoryId: 4, categoryName: "MOS", duration: "00:30"),
		Service.init(id: 9, name: "MOS- Stretch Marks", color: "#FEC87C", categoryId: 4, categoryName: "MOS", duration: "00:30")
	]

	var groupedServices: [Int: [Service]] {
		 return [Int: [Service]].init(grouping: services, by: { $0.categoryId })
	}

	var listServices: [[Service]] {
		let res = self.groupedServices.map({ $0.value })
			.sorted(by: { $0.first!.categoryId > $1.first!.categoryId})
		print(res)
		return res
	}
}

public enum ChooseServiceAction {
	case didSelectServiceId(Int)
	case didSelectFilter(ChooseServiceFilter)
	case didTapBackBtn
}

struct FillAll: View {
    let color: Color
    var body: some View {
        GeometryReader { proxy in
            self.color.frame(width: proxy.size.width * 1.3).fixedSize()
        }
    }
}

struct ChooseService: View {
	let store: Store<ChooseServiceState, ChooseServiceAction>
	@ObservedObject var viewStore: ViewStore<ChooseServiceState>
	init (store: Store<ChooseServiceState, ChooseServiceAction>) {
		self.store = store
		self.viewStore = self.store.view
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
	}

	@State var searchText: String = ""
	var body: some View {
		VStack {
			HStack {
				TextField("TODO: search: ", text: self.$searchText)
				StaffFilterPicker()
			}
			List {
				ForEach(self.viewStore.value.listServices, id: \.self.first?.categoryId) { (group: [Service]) in
					Section(header:
						ServicesHeader(name: group.first?.categoryName ?? "No name")
					) {
						ForEach(group, id: \.self) { (service: Service) in
							ServiceRow(service: service)
						}.onTapGesture {
							self.store.send(.didTapBackBtn)
						}
					}.background(Color.white)
				}
			}
			Spacer()
		}
		.padding()
		.navigationBarTitle("Services")
		.customBackButton(action: { self.store.send(.didTapBackBtn)})

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

struct ServiceRow: View {
	let service: Service
	var body: some View {
		HStack {
			Circle()
				.fill(Color.init(hex: service.color))
				.frame(width: 22.0, height: 22.0)
			Text(service.name).font(.regular17)
			Spacer()
			Text(service.duration ?? "Not set").font(.regular17)
		}
	}
}

struct ServicesHeader: View {
	let name: String
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Spacer()
			Text(name).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
			Divider()
		}
	}
}