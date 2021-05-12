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
