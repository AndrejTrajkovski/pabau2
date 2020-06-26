import SwiftUI
import ComposableArchitecture
import Util

struct InjectablesState: Equatable {
	var usedInjections: [Injection]
	var allProducts: [Injectable]
}

public enum InjectablesAction: Equatable {
	case onSelectInjectableId(Int)
}

struct InjectablesList: View {
	
	struct ViewState: Equatable {
		let sections: [SectionViewModel]
	}
	
	let store: Store<InjectablesState, InjectablesAction>
	@State var searchText: String = ""
	
	var body: some View {
		WithViewStore(
			store.scope(state: { ViewState.init(state:$0) })) { viewStore in
			NavigationView {
				VStack {
					HStack {
						TextField("TODO: search: ", text: self.$searchText)
						StaffFilterPicker()
					}
					List {
						ForEach(viewStore.state.sections.indices) { sectionIdx in
							return self.makeSection(viewStore.state.sections[sectionIdx]) {
								viewStore.send(.onSelectInjectableId($0))
							}
						}
					}
					Spacer()
				}
				.padding()
				.navigationBarTitle("Injectables")
			}
		}
	}
	
	func makeSection(_ viewModel: SectionViewModel,
									 _ onSelectId: @escaping (Int) -> Void) -> some View {
		Section(header:
			InjectableHeader(viewModel: viewModel.header)
		) {
			ForEach(viewModel.items.indices) { (idx: Int) in
				AllInjectablesRow(viewModel: viewModel.items[idx])
				.onTapGesture {
					onSelectId(viewModel.items[idx].injectableId)
				}
			}
		}
		.background(Color.white)
	}
}

struct AllInjectablesRow: View {
	let viewModel: InjectablesList.ListItemViewModel
	var body: some View {
		ColorCircleRow(title: viewModel.title,
									 subtitle: viewModel.subtitle,
									 color: viewModel.color)
	}
}

struct InjectableHeader: View {
	let viewModel: InjectablesList.HeaderViewModel
	var body: some View {
		HStack {
			Text(viewModel.title)
			Spacer()
			Text(viewModel.subtitle)
		}.font(.bold17)
	}
}

extension InjectablesList {
	
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
}

typealias GroupedInj = Dictionary<Injectable, TotalInjAndUnits>

extension InjectablesList.ViewState {
	init(state: InjectablesState) {
		let usedHeader = InjectablesList.HeaderViewModel(title: Texts.usedInProcedure,
																								 subtitle: Texts.total)
		let rows = state.usedInjections.reduce(into: GroupedInj.init(), { res, element in
			if res[element.injectable] == nil {
				res[element.injectable] = TotalInjAndUnits()
			}
			res[element.injectable]!.totalUnits += element.units
			res[element.injectable]!.totalInj += 1
			})
			.sorted(by: { lhs, rhs in
				if let index1 = state.usedInjections.firstIndex(where: {
					lhs.key == $0.injectable
				}).map({ Int($0)}),
					let index2 = state.usedInjections.firstIndex(where: {
						rhs.key == $0.injectable
					}).map({ Int($0)}) {
					return index1 > index2
				} else {
					return false
				}
			})
			.map { injectable, totals in
				InjectablesList.ListItemViewModel(title: injectable.title,
																			subtitle: String(totals.totalInj) + " injections - " + String(totals.totalUnits) + " units",
					color: injectable.color,
					injectableId: injectable.id)
		}
		let section1 = InjectablesList.SectionViewModel(header: usedHeader,
																								items: rows)
		let allHeader = InjectablesList.HeaderViewModel(title: Texts.allProducts,
																								subtitle: Texts.increment)
		let allProducts = state.allProducts.map {
			InjectablesList.ListItemViewModel(title: $0.title, subtitle: String($0.increment), color: $0.color, injectableId: $0.id)
		}
		let section2 = InjectablesList.SectionViewModel(header: allHeader,
																								items: allProducts)
		self.sections = [section1, section2]
	}
}

struct TotalInjAndUnits {
	var totalInj: Int = 0
	var totalUnits: Double = 0
}

public struct Injection: Equatable, Identifiable {
	public let id: UUID = UUID()
	let injectable: Injectable
	var units: Double
	var position: CGPoint
}

public struct Injectable: Hashable {
	let id: Int
	let color: Color
	let title: String
	var increment: Double
}
