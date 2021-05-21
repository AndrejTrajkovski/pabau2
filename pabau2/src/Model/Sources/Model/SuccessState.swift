public struct SuccessState<Model> {
    public var state: Model
    public var isFromDB: Bool
    
    public init(state: Model, isFromDB: Bool) {
        self.state = state
        self.isFromDB = isFromDB
    }
	
	public func callAsFunction() -> Model {
	  return state
	}
}

extension SuccessState: Equatable where Model: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state && lhs.isFromDB == rhs.isFromDB
	}
}
