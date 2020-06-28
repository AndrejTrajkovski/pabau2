import SwiftUI
import ComposableArchitecture
import Util

public let chooseInjectableReducer = Reducer<ChooseInjectablesState, ChooseInjectableAction, JourneyEnvironment>.init { state, action, _ in
	//FIXME: please
	switch action {
	case .onSelectInjectableId(let id):
		let chosenInjectable = state.allInjectables.first(where: {
			$0.id == id
		})!
		state.stepper = InjectableStepperState(injectable: chosenInjectable)
	case .onSelectUsedInjectableId(let id):
		let chosenInjectable = state.allInjectables.first(where: {
			$0.id == id
		})!
		let chosenInjectionsByInjectable = state.photoInjections.first (where: {
			$0.injectableId == id
		})!
		state.stepper = InjectableStepperState(usedInjections: chosenInjectionsByInjectable,
																					 injectable: chosenInjectable)
	}
	state.isChooseInjectablesActive = false
	return .none
}

public struct ChooseInjectablesState: Equatable {
	var allInjectables: [Injectable]
	var photoInjections: IdentifiedArrayOf<InjectionsAndActive>
	var isChooseInjectablesActive: Bool
	var stepper: InjectableStepperState?
	var canvas: InjectablesCanvasState?
}

public enum ChooseInjectableAction: Equatable {
	case onSelectUsedInjectableId(Int)
	case onSelectInjectableId(Int)
}

struct ChooseInjectable: View {

	struct ViewState: Equatable {
		let sections: [SectionViewModel]
	}
	
	let store: Store<ChooseInjectablesState, ChooseInjectableAction>
	@State var searchText: String = ""
	var body: some View {
		NavigationView {
			VStack {
				HStack {
					TextField("TODO: search: ", text: self.$searchText)
					StaffFilterPicker()
				}
				List {
					UsedInjectionsSection(
						store: self.store.scope(
							state: { $0 },
							action: { $0 })
					)
					RestOfInjectionsSection(
						store: self.store.scope(
							state: { $0 },
							action: { $0 })
					)
				}
				Spacer()
			}
			.padding()
			.navigationBarTitle("Injectables")
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct UsedInjectionsSection: View {
	let store: Store<ChooseInjectablesState, ChooseInjectableAction>
	@ObservedObject var viewStore: ViewStore<SectionViewModel, ChooseInjectableAction>

	init (store: Store<ChooseInjectablesState, ChooseInjectableAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(
			state: SectionViewModel.init(used:),
			action: { $0 }))
	}

	var body: some View {
		ChooseInjectableSection(
			viewModel: viewStore.state,
			onSelectId: {
			self.viewStore.send(.onSelectUsedInjectableId($0))
		})
	}
}

struct RestOfInjectionsSection: View {
	let store: Store<ChooseInjectablesState, ChooseInjectableAction>
	@ObservedObject var viewStore: ViewStore<SectionViewModel, ChooseInjectableAction>
	init (store: Store<ChooseInjectablesState, ChooseInjectableAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(
			state: SectionViewModel.init(all:),
			action: { $0 }))
	}
	var body: some View {
		ChooseInjectableSection(
			viewModel: viewStore.state,
			onSelectId: {
				self.viewStore.send(.onSelectInjectableId($0))
		})
	}
}

extension SectionViewModel {
	init (used: ChooseInjectablesState) {
		self.header = HeaderViewModel(title: Texts.usedInProcedure,
																	subtitle: Texts.total)
		self.items = used.photoInjections.map { injection in
			let injectable = used.allInjectables.first(where: { $0.id == injection.injectableId })
			let totals = injection.totals
			let subtitle = String(totals.totalInj) + " injections - " + String(totals.totalUnits) + " units"
			return ListItemViewModel(title: injectable?.title ?? "",
															 subtitle: subtitle,
															 color: injectable?.color ?? .white,
															 injectableId: injection.id)
		}
	}
}

extension SectionViewModel {
	init(all: ChooseInjectablesState) {
		self.header = HeaderViewModel(title: Texts.allProducts,
																	subtitle: Texts.increment)
		self.items = all.allInjectables
			.filter {
				!all.photoInjections.map(\.injectableId).contains($0.id)
		}
		.map {
			ListItemViewModel(title: $0.title, subtitle: String($0.increment), color: $0.color, injectableId: $0.id)
		}
	}
}

struct ChooseInjectableSection: View {
	let viewModel: SectionViewModel
	let onSelectId: (Int) -> Void
	
	var body: some View {
		Section(header:
			InjectableHeader(viewModel: self.viewModel.header)
		) {
			ForEach(viewModel.items.indices) { (idx: Int) in
				AllInjectablesRow(viewModel: self.viewModel.items[idx])
					.onTapGesture {
						self.onSelectId(self.viewModel.items[idx].injectableId)
				}
			}
		}
		.background(Color.white)
	}
}

struct AllInjectablesRow: View {
	let viewModel: ListItemViewModel
	var body: some View {
		ColorCircleRow(title: viewModel.title,
									 subtitle: viewModel.subtitle,
									 color: viewModel.color)
	}
}

struct InjectableHeader: View {
	let viewModel: HeaderViewModel
	var body: some View {
		HStack {
			Text(viewModel.title)
			Spacer()
			Text(viewModel.subtitle)
		}.font(.bold17)
	}
}
	
struct SectionViewModel: Equatable {
	let header: HeaderViewModel
	let items: [ListItemViewModel]
}

struct HeaderViewModel: Equatable {
	let title: String
	let subtitle: String
}

struct ListItemViewModel: Equatable {
	let title: String
	let subtitle: String
	let color: Color
	let injectableId: Int
}

struct TotalInjAndUnits {
	var totalInj: Int = 0
	var totalUnits: Double = 0
}

public struct Injection: Equatable, Identifiable {
	public let id: UUID = UUID()
	var units: Double
	var position: CGPoint
}

public struct Injectable: Hashable {
	let id: InjectableId
	let color: Color
	let title: String
	var increment: Double
}