public struct SignatureState: Codable, Equatable {
	
	public var signatureUrl: String?
	
	public var drawings = [SignatureDrawing]()
	public mutating func resetDrawings() {
		self.drawings = [SignatureDrawing]()
	}
}
