public struct User: Equatable {
	public init(id: Int = 0, name: String = "") {
		self.id = id
		self.name = name
	}

	let id: Int
	let name: String
}
