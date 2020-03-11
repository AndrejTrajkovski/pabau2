public enum LoginError: Error {
	case wrongCredentials
	case requestError(RequestError)
}
