public enum StepStatus: String, Decodable, Equatable {
	case complete
	case skipped
	case pending
    
    public init(formStatus: FormStatus?) {
        switch formStatus {
        case .complete:
            self = .complete
        case .pending, nil:
            self = .pending
        }
    }
}
