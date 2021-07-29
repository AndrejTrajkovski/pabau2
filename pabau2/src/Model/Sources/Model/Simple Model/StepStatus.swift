public enum StepStatus: String, Decodable, Equatable {
	case completed
	case skipped
	case pending
    
    public init(formStatus: FormStatus?) {
        switch formStatus {
        case .complete:
            self = .completed
        case .pending, nil:
            self = .pending
        }
    }
}
