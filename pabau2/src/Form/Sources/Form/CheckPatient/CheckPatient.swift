import Model
import Foundation

public struct CheckPatient: Equatable, Identifiable {
	public let id: Step.ID
	var clientBuilder: ClientBuilder?
	var patForms: [HTMLForm]

	public init (
		id: Step.Id,
		clientBuilder: ClientBuilder?,
		patForms: [HTMLForm]
	) {
		self.id = id
		self.clientBuilder = clientBuilder
		self.patForms = patForms
	}
}
