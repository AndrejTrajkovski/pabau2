public struct SignatureState: Codable, Equatable {
	var signatureUrl: String
	public var drawings = [SignatureDrawing]()
	public mutating func resetDrawings() {
		self.drawings = [SignatureDrawing]()
	}
	public init (signatureUrl: String) {
		self.signatureUrl = signatureUrl
	}
}
