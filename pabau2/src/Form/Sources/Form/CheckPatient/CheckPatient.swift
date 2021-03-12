import Model
import Foundation

public struct CheckPatient: Equatable, Identifiable {
	public let id: UUID = UUID()
	let clientBuilder: ClientBuilder
	let patForms: [HTMLForm]

	public init (
		clientBuilder: ClientBuilder,
		patForms: [HTMLForm]
	) {
		self.clientBuilder = clientBuilder
		self.patForms = patForms
	}
}
