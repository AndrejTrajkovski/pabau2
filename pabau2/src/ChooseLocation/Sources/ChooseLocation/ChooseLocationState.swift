import Model
import ComposableArchitecture

public struct ChooseLocationState: Equatable {
	public var isChooseLocationActive: Bool
	public var locations: IdentifiedArrayOf<Location> = []
	public var filteredLocations: IdentifiedArrayOf<Location> = []
	public var chosenLocation: Location?
	public var searchText: String = "" {
		didSet {
			isSearching = !searchText.isEmpty
		}
	}
	public var isSearching = false

	public init(isChooseLocationActive: Bool) {
		self.isChooseLocationActive = isChooseLocationActive
	}
}
