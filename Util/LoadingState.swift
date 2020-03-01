public enum LoadingState<Value> {
	case initial
	case loading
	case gotSuccess(Value)
	case gotError(Error)
	public var isLoading: Bool {
		guard case LoadingState.loading = self else { return false }
		return true
	}
}
