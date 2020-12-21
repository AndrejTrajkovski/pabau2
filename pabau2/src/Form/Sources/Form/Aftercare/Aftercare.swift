import Foundation

public struct Aftercare: Equatable, Identifiable {
	public var id: UUID = UUID()
	public init (
		profile: SingleSelectImages,
		share: SingleSelectImages,
		aftercares: [AftercareOption],
		recalls: [AftercareOption]
	) {
		self.profile = profile
		self.share = share
		self.aftercares = aftercares
		self.recalls = recalls
	}

	var profile: SingleSelectImages
	var share: SingleSelectImages
	var aftercares: [AftercareOption]
	var recalls: [AftercareOption]
}
