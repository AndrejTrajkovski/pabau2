public enum LoadingState<Value: Equatable, Error: Equatable>: Equatable {
	public static func == (lhs: LoadingState<Value, Error>, rhs: LoadingState<Value, Error>) -> Bool {
		switch (lhs, rhs) {
		case (.initial, .initial):
			return true
		case (.loading, .loading):
			return true
		case (let .gotSuccess(lhsValue), let .gotSuccess(rhsValue)):
			return lhsValue == rhsValue
		case (let .gotError(lhsError), let .gotError(rhsError)):
			return lhsError == rhsError
		default:
			return true
		}
	}
	
	case initial
	case loading
	case gotSuccess(Value)
	case gotError(Error)
	public var isLoading: Bool {
		guard case LoadingState.loading = self else { return false }
		return true
	}
}
