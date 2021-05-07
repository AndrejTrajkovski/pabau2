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
