
public struct PathwayIdStepId {
	
	public init(step_id: Step.ID, path_taken_id: Pathway.ID) {
		self.step_id = step_id
		self.path_taken_id = path_taken_id
	}
	
	let step_id: Step.ID
	let path_taken_id: Pathway.ID
}

extension EitherStringOrInt: Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .left(let string):
			try container.encode(string)
		case .right(let int):
			try container.encode(int)
		}
	}
}
