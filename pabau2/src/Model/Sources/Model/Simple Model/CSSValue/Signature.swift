public struct Signature: Codable, Equatable {
	public var drawings = [SignatureDrawing]()
	public mutating func resetDrawings() {
		self.drawings = [SignatureDrawing]()
	}
	public init () {}
}
