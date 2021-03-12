public enum Salutation: String, CaseIterable, Equatable, CustomStringConvertible, Identifiable {
	public var description: String { self.rawValue }
	
	case mister = "Mr."
	case miss = "Ms."
	case mrs = "Mrs."
	case misses = "Miss."
	case doctor = "Dr."
	case master = "Master."
	case professor = "Professor."
	
	public var id: String { self.rawValue }
}
