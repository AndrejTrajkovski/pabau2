import Tagged

public struct Pathway: Decodable, Identifiable, Equatable {

	public typealias ID = Tagged<Pathway, EitherStringOrInt>
	
	public let id: ID

	public let stepEntries: [Step.ID: StepEntry]
}
