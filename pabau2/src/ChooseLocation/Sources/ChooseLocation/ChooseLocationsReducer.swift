import SwiftUI
import Model
import ComposableArchitecture
import Util
import CoreDataModel

public let chooseLocationsParentReducer: Reducer<ChooseLocationState?, ChooseLocationAction, ChooseLocationEnvironment> =
	.combine(
		.init { state, action, env in
			switch action {
				
			case .didSelectLocation(let locationId):
				
				state = nil
				
			case .didTapBackBtn:
				
				state = nil
				
			case .reload:
				
				break
				
			case .gotLocationsResponse(_):
				
				break
				
			case .onSearch(_):
			
				break
			}
			
			return .none
		},
		chooseLocationsReducer.optional().pullback(
			state: \.self,
			action: /.self,
			environment: { $0 }
		)
	)

public let chooseLocationsReducer =
    Reducer<ChooseLocationState, ChooseLocationAction, ChooseLocationEnvironment> { state, action, env in
        switch action {
		
        case .reload:
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
                state.locations = .init(result())
                state.filteredLocations = state.locations
            case .failure(let error):
                print(error)
            }
            
            return .none //TODO SAVE TO DB with fireAndForget()
		
        case .didSelectLocation(let locationId):
			
            state.chosenLocationId = locationId
			
        case .didTapBackBtn:
			
			break
			
        }
        return .none
    }
