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
    switch action {
    case .onAppear:
        state.searchText = ""
		
        return env.storage.fetchAllSchemes(BookoutReasonScheme.self)
            .catchToEffect()
            .receive(on: DispatchQueue.main)
            .map(ChooseBookoutReasonAction.gotStoredReasonResponse)
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
        case .success(let reasons):
            reasons.forEach { $0.save(to: env.storage) }
            
            state.reasons = .init(reasons)
            state.filteredReasons = state.reasons
        case .failure:
            break
        }
    case .gotStoredReasonResponse(let result):
        switch result {
        case .success(let schemes):
            if schemes.isEmpty {
                return env.clientAPI.getBookoutReasons()
                    .catchToEffect()
                    .receive(on: DispatchQueue.main)
                    .map(ChooseBookoutReasonAction.gotReasonResponse)
                    .eraseToEffect()
            }

            var reasons = schemes.compactMap {
                BookoutReason(id: $0.id, name: $0.name, color: $0.color)
            }
       
            state.reasons = .init(reasons)
            state.filteredReasons = state.reasons
        case .failure:
            return env.clientAPI.getBookoutReasons()
                .catchToEffect()
                .receive(on: DispatchQueue.main)
                .map(ChooseBookoutReasonAction.gotReasonResponse)
                .eraseToEffect()
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
	case gotReasonResponse(Result<[BookoutReason], RequestError>)
	case gotStoredReasonResponse(Result<[BookoutReasonScheme], CoreDataModelError>)
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
