//public enum ResetPassBackendError: Error {
//	case emailNotSent
//	case genericBackendError(RequestError)
//}
//
//extension ResetPassBackendError: Equatable {
//	public static func == (lhs: ResetPassBackendError, rhs: ResetPassBackendError) -> Bool {
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
