public struct SignatureState: Codable, Equatable {
	
	public var signatureUrl: String?
	
	public var isSigning: Bool = false
	public var drawings = [SignatureDrawing]()
	public mutating func resetDrawings() {
		self.drawings = [SignatureDrawing]()
	}
	public init(signatureUrl: String?) {
		self.signatureUrl = signatureUrl
	}
}
