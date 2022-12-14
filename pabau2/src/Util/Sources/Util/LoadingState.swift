public enum LoadingState: Equatable {
	public static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
		switch (lhs, rhs) {
		case (.initial, .initial), (.loading, .loading), (.gotSuccess, .gotSuccess),
				 (.gotError, .gotError):
			return true
		default:
			return false
		}
	}

	case initial
	case loading
	case gotSuccess
	case gotError(Error)
	public var isLoading: Bool {
		guard case LoadingState.loading = self else { return false }
		return true
	}

    public var isError: Bool {
        guard case LoadingState.gotError(_) = self else { return false }
        return true
    }
}
