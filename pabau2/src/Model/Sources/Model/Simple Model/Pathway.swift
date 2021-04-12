import Tagged

public struct Pathway: Decodable, Identifiable, Equatable {

	public typealias ID = Tagged<Pathway, Int>
	
	public let id: ID

	public let steps: [Step.ID: FormStepEntry]
}
