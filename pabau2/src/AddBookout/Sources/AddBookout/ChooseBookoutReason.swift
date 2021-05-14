import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents
import CoreDataModel

let chooseBookoutReasonReducer = Reducer<
    ChooseBookoutReasonState,
    ChooseBookoutReasonAction,
    AddBookoutEnvironment
> { state, action, env in
    struct LoadBookoutReasons: Hashable {}

    switch action {
    case .onAppear:
        state.searchText = ""
        return env.repository.getBookoutReasons()
            .catchToEffect()
            .receive(on: DispatchQueue.main)
            .map(ChooseBookoutReasonAction.gotReasonResponse)
            .eraseToEffect()
    case .onSearch(let text):
        state.searchText = text
        if state.searchText.isEmpty {
            state.filteredReasons = state.reasons
            break
        }
        
        state.filteredReasons = state.reasons.filter {($0.name?.lowercased().contains(text.lowercased()) ?? false)}
    case .gotReasonResponse(let result):
        switch result {
        case .success(let response):
            log(response.isDB, text: "is from db")
            state.reasons = .init(response.value)
            state.filteredReasons = state.reasons
        case .failure:
            break
        }
    case .didSelectReason(let reason):
        state.chosenReasons = reason
        state.isChooseBookoutReasonActive = false
    case .didTapBackBtn:
        state.isChooseBookoutReasonActive = false
    }
    return .none
}

public struct ChooseBookoutReasonState: Equatable {
	public var isChooseBookoutReasonActive: Bool
	public var reasons: IdentifiedArrayOf<BookoutReason> = []
	public var filteredReasons: IdentifiedArrayOf<BookoutReason> = []
	public var chosenReasons: BookoutReason?
	public var searchText: String = "" {
		didSet {
			isSearching = !searchText.isEmpty
		}
	}
	public var isSearching = false
	
	public init(isChooseBookoutReasonActive: Bool) {
		self.isChooseBookoutReasonActive = isChooseBookoutReasonActive
	}
}

public enum ChooseBookoutReasonAction: Equatable {
	case onAppear
	case gotReasonResponse(Result<Repository.BookoutReasonsResponse, RequestError>)
	case didSelectReason(BookoutReason)
	case onSearch(String)
	case didTapBackBtn
}

public struct ChooseBookoutReasonView: View {
	let store: Store<ChooseBookoutReasonState, ChooseBookoutReasonAction>
	@ObservedObject var viewStore: ViewStore<ChooseBookoutReasonState, ChooseBookoutReasonAction>
	
	public init(store: Store<ChooseBookoutReasonState, ChooseBookoutReasonAction>) {
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
					send: ChooseBookoutReasonAction.onSearch)
			)
			List {
				ForEach(self.viewStore.state.filteredReasons, id: \.id) { reason in
					TextAndCheckMark(
						reason.name ?? "",
						reason.id == self.viewStore.state.chosenReasons?.id
					).onTapGesture {
						self.viewStore.send(.didSelectReason(reason))
					}
				}
			}
		}
		.onAppear {
			self.viewStore.send(.onAppear)
		}
		.padding()
		.navigationBarTitle("Reasons")
		.customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
	}
}
