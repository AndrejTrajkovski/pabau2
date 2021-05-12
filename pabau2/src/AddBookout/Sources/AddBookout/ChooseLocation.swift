
import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents

let chooseLocationsReducer =
    Reducer<ChooseLocationState, ChooseLocationAction, AddBookoutEnvironment> { state, action, env in
        switch action {
        case .onAppear:
            state.searchText = ""
            return env.repository.journeyAPI.getLocations()
                .catchToEffect()
                .receive(on: DispatchQueue.main)
                .map(ChooseLocationAction.gotLocationsResponse)
                .eraseToEffect()
        case .onSearch(let text):
            state.searchText = text
            if state.searchText.isEmpty {
                state.filteredLocations = state.locations
                break
            }
            
            state.filteredLocations = state.locations.filter {$0.name.lowercased().contains(text.lowercased())}
        case .gotLocationsResponse(let result):
            switch result {
            case .success(let location):
                state.locations = .init(location)
                state.filteredLocations = state.locations
            case .failure(let error):
                print(error)
            }
        case .didSelectLocation(let location):
            state.chosenLocation = location
            state.isChooseLocationActive = false
        case .didTapBackBtn:
            state.isChooseLocationActive = false
        }
        return .none
    }
