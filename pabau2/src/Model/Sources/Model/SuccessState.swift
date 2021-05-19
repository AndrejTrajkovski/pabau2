//public enum SuccessState<Model> {
//	case db(Model)
//	case api(Model)
//
//	public func get() -> Model {
//		switch self {
//		case .api(let value):
//			return value
//		case .db(let value):
//			return value
//		}
//	}
//}

public struct SuccessState<Model> {
    public var state: Model
    public var isFromDB: Bool
    
    public init(state: Model, isFromDB: Bool) {
        self.state = state
        self.isFromDB = isFromDB
    }
}

extension SuccessState: Equatable where Model: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state && lhs.isFromDB == rhs.isFromDB
	}
}

//extension Result {
//	public func toAPI() -> Result<SuccessState<Success>, Failure> {
//        self.map(SuccessState<Success>.init(state: , isFromDB: false))
//	}
//	
//	public func toDB() -> Result<SuccessState<Success>, Failure> {
//		self.map(SuccessState.db)
//	}
//}
