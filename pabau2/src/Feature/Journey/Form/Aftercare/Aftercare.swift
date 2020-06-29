public struct Aftercare: Equatable, Identifiable {
	public var id: UUID = UUID()
	var profile: SingleSelectImages
	var share: SingleSelectImages
	var aftercares: [AftercareOption]
	var recalls: [AftercareOption]
}
