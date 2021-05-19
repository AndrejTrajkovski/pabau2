import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents
import CoreDataModel

let chooseLocationsReducer =
    Reducer<ChooseLocationState, ChooseLocationAction, AddShiftEnvironment> { state, action, env in
        switch action {
        case .onAppear:
            state.searchText = ""
            return env.repository.getLocations()
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
            case .success(let result):
				state.locations = .init(result.state)
                state.filteredLocations = state.locations
            case .failure(let error):
                print(error)
            }

			return .none //TODO SAVE TO DB with fireAndForget()
        case .didSelectLocation(let location):
            state.chosenLocation = location
            state.isChooseLocationActive = false
        case .didTapBackBtn:
            state.isChooseLocationActive = false
        }
        return .none
    }
