import Model
import ComposableArchitecture
import Util

public struct ChooseLocationState: Equatable {
	public var locations: IdentifiedArrayOf<Location>
	public var filteredLocations: IdentifiedArrayOf<Location>
	public var chosenLocationId: Location.Id?
	public var searchText: String = ""
	public var locationsLS: LoadingState = .initial
	
	public init(locations: IdentifiedArrayOf<Location>,
				chosenLocationId: Location.Id?) {
		self.locations = locations
		self.chosenLocationId = chosenLocationId
		self.filteredLocations = locations
	}
}
