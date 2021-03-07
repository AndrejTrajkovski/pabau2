import Model
import Foundation

public struct CheckPatient: Equatable, Identifiable {
	public let id: UUID = UUID()
	let patDetails: ClientBuilder
	let patForms: [HTMLForm]

	public init (
		patDetails: ClientBuilder,
		patForms: [HTMLForm]
	) {
		self.patDetails = patDetails
		self.patForms = patForms
	}
}
