import Model

public enum ChooseLocationAction: Equatable {
	case reload
	case gotLocationsResponse(Result<SuccessState<[Location]>, RequestError>)
	case didSelectLocation(Location.Id)
	case onSearch(String)
	case didTapBackBtn
}
