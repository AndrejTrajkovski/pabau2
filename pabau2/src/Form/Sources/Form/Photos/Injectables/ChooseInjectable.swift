import SwiftUI
import ComposableArchitecture
import Util

public let chooseInjectableReducer = Reducer<ChooseInjectablesState, ChooseInjectableAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .onSelectInjectableId(let id):
		state.chosenInjectableId = id
		state.isChooseInjectablesActive = false
	case .onSelectUsedInjectableId(let id):
		state.chosenInjectableId = id
		state.isChooseInjectablesActive = false
	case .onDismissChooseInjectables:
		state.isChooseInjectablesActive = false
	}
	return .none
}

public struct ChooseInjectablesState: Equatable {
	var allInjectables: IdentifiedArrayOf<Injectable>
	var photoInjections: [InjectableId: IdentifiedArrayOf<Injection>]
	var isChooseInjectablesActive: Bool
	var chosenInjectableId: InjectableId?
}

public enum ChooseInjectableAction: Equatable {
	case onSelectUsedInjectableId(Int)
	case onSelectInjectableId(Int)
	case onDismissChooseInjectables
}

struct ChooseInjectable: View {

	let store: Store<ChooseInjectablesState, ChooseInjectableAction>
	@State var searchText: String = ""
	var body: some View {
		WithViewStore(store.stateless) { viewStore in
			NavigationView {
				VStack {
					TextField("Search: ", text: self.$searchText)
						.padding()
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
				.navigationBarTitle(Text(Texts.injectables), displayMode: .inline)
				.navigationBarItems(leading:
					Button.init(action: { viewStore.send(.onDismissChooseInjectables) }, label: {
						Image(systemName: "xmark")
							.font(Font.light30)
							.foregroundColor(.gray142)
							.frame(width: 30, height: 30)
					})
				)
			}.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}

struct UsedInjectionsSection: View {
	let store: Store<ChooseInjectablesState, ChooseInjectableAction>
	@ObservedObject var viewStore: ViewStore<SectionViewModel?, ChooseInjectableAction>

	init (store: Store<ChooseInjectablesState, ChooseInjectableAction>) {
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
		self.store = store
		self.viewStore = ViewStore(store.scope(
			state: SectionViewModel.init(used:),
			action: { $0 }))
	}

	var body: some View {
		Group {
			if viewStore.state != nil {
				ChooseInjectableSection(
					viewModel: viewStore.state!,
					onSelectId: {
						self.viewStore.send(.onSelectUsedInjectableId($0))
				})
			} else {
				EmptyView()
			}
		}
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
	init?(used: ChooseInjectablesState) {
		guard !used.photoInjections.isEmpty else { return nil }
		self.header = HeaderViewModel(title: Texts.usedInProcedure,
																	subtitle: Texts.total)
		self.items = used.photoInjections.map { dictionary in
			let injectable = used.allInjectables.first(where: { $0.id == dictionary.key })
			let totals = dictionary.value.reduce(into: TotalInjAndUnits(), {
				$0.totalInj += 1
				$0.totalUnits += $1.units
			})
			let subtitle = String(totals.totalInj) + " injections - " + String(totals.totalUnits) + " units"
			return ListItemViewModel(title: injectable?.title ?? "",
															 subtitle: subtitle,
															 color: injectable?.color ?? .white,
															 injectableId: dictionary.key)
		}
	}
}

extension SectionViewModel {
	init(all: ChooseInjectablesState) {
		self.header = HeaderViewModel(title: Texts.allProducts,
																	subtitle: Texts.increment)
		self.items = all.allInjectables
			.filter {
				!all.photoInjections.map(\.key).contains($0.id)
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
