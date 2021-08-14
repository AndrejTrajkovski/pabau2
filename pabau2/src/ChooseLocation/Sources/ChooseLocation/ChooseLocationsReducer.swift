import SwiftUI
import Model
import ComposableArchitecture
import Util
import CoreDataModel

struct GetLocationsId: Hashable { }

public let chooseLocationsParentReducer: Reducer<ChooseLocationState?, ChooseLocationAction, ChooseLocationEnvironment> =
	.combine(
		chooseLocationsReducer.optional().pullback(
			state: \.self,
			action: /.self,
			environment: { $0 }
		),
		.init { state, action, _ in
			switch action {
				
			case .didSelectLocation(let locationId):
				
				state = nil
				return .cancel(id: GetLocationsId())
				
			case .didTapBackBtn:
				
				state = nil
				return .cancel(id: GetLocationsId())
				
			case .reload:
				
				break
				
			case .gotLocationsResponse(_):
				
				break
				
			case .onSearch(_):
			
				break
			}
			
			return .none
		}
	)

public let chooseLocationsReducer =
    Reducer<ChooseLocationState, ChooseLocationAction, ChooseLocationEnvironment> { state, action, env in
        switch action {
		
        case .reload:
			
            state.searchText = ""
			state.locationsLS = .loading
			
            return env.repository.getLocations()
                .catchToEffect()
                .receive(on: DispatchQueue.main)
                .map(ChooseLocationAction.gotLocationsResponse)
                .eraseToEffect()
				.cancellable(id: GetLocationsId())
			
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
                state.locations = IdentifiedArrayOf(uniqueElements: result())
                state.filteredLocations = state.locations
				state.locationsLS = .gotSuccess
            case .failure(let error):
				state.locationsLS = .gotError(error)
                print(error)
            }
		
        case .didSelectLocation(let locationId):
			
            state.chosenLocationId = locationId
			
        case .didTapBackBtn:
			
			break
			
        }
        return .none
    }
