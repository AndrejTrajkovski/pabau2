//public enum RequestError: Error {
//	case emailNotSent
//	case genericBackendError(RequestError)
//}
//
//extension RequestError: Equatable {
//	public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
//		switch (lhs, rhs) {
//		case (.emailNotSent, .emailNotSent):
//			return true
//		case (.genericBackendError(let lhsOther), (.genericBackendError(let rhsOther))):
//			return lhsOther == rhsOther
//		default:
//			return false
//		}
//	}
//}
