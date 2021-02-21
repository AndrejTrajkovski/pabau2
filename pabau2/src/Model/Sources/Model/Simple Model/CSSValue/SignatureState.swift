public struct SignatureState: Equatable {
	
	init(signatureUrl: String?) {
		self.signatureUrl = signatureUrl
	}
	
	public var isSigning: Bool = false
	public var currentDrawings: [SignatureDrawing] = []
	public var signatureUrl: String?
}

public struct DrawingPadState: Equatable {
	public init(currentDrawing: SignatureDrawing = SignatureDrawing(),
				drawings: [SignatureDrawing] = [SignatureDrawing]()) {
		self.currentDrawing = currentDrawing
		self.drawings = drawings
	}
	
	public var currentDrawing = SignatureDrawing()
	public var drawings = [SignatureDrawing]()
}
