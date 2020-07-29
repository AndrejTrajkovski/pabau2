public enum ForgotPassError: Error, Equatable {
	case serviceNotAvailable
	case requestError(RequestError)
}
