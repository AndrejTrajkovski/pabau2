import SwiftUI
import Model
import ComposableArchitecture
import Util

let chooseServiceReducer =
	Reducer<ChooseServiceState, ChooseServiceAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didSelectFilter(let filter):
		state.filterChosen = filter
	case .didSelectServiceId(let serviceID):
		state.chosenServiceId = serviceID
		state.isChooseServiceActive = false
	case .didTapBackBtn:
		state.isChooseServiceActive = false
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

public enum ChooseServiceAction: Equatable {
	case didSelectServiceId(Int)
	case didSelectFilter(ChooseServiceFilter)
	case didTapBackBtn
}

struct ChooseService: View {
	let store: Store<ChooseServiceState, ChooseServiceAction>
	@ObservedObject var viewStore: ViewStore<ChooseServiceState, ChooseServiceAction>
	init (store: Store<ChooseServiceState, ChooseServiceAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
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
				ForEach(self.viewStore.state.listServices, id: \.self.first?.categoryId) { (group: [Service]) in
					Section(header:
						TextHeader(name: group.first?.categoryName ?? "No name")
					) {
						ForEach(group, id: \.self) { (service: Service) in
							ServiceRow(service: service).onTapGesture {
								self.viewStore.send(.didSelectServiceId(service.id))
							}
						}
					}.background(Color.white)
				}
			}
			Spacer()
		}
		.padding()
		.navigationBarTitle("Services")
		.customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
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

struct TextHeader: View {
	let name: String
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Spacer()
			Text(name).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
			Divider()
		}
	}
}
