import Model

public enum ChooseLocationAction: Equatable {
	case onAppear
	case gotLocationsResponse(Result<SuccessState<[Location]>, RequestError>)
	case didSelectLocation(Location)
	case onSearch(String)
	case didTapBackBtn
}
