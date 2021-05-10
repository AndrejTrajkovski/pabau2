import SwiftUI
import ComposableArchitecture
import Util
import Model
import CoreDataModel

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
