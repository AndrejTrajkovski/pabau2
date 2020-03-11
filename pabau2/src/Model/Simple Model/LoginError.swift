public enum LoginError: Error, Equatable {
	case wrongCredentials
	case requestError(RequestError)
}
