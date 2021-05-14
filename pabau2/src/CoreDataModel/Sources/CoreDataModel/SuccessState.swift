public enum SuccessState<Model> {
	case db(Model)
	case api(Model)
	
	public func get() -> Model {
		switch self {
		case .api(let value):
			return value
		case .db(let value):
			return value
		}
	}
}

extension SuccessState: Equatable where Model: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
		case (.db(let lhdb), .db(let rhdb)):
			return lhdb == rhdb
		case (.api(let lhapi), .api(let rhapi)):
			return lhapi == rhapi
		default:
			return false
		}
	}
}

extension Result {
	public func toAPI() -> Result<SuccessState<Success>, Failure> {
		self.map(SuccessState.api)
	}
	
	public func toDB() -> Result<SuccessState<Success>, Failure> {
		self.map(SuccessState.db)
	}
}
