import CoreGraphics
import UIKit

public struct SignatureState: Equatable {
	
	init(signatureUrl: String?) {
		self.signatureUrl = signatureUrl
	}
	
	public var isSigning: Bool = false
	public var currentDrawings: [SignatureDrawing] = []
	public var canvasSize: CGSize?
	public var signatureUrl: String?
	
	public func image() -> UIImage? {
		canvasSize.map {
			print($0)
			return image(canvasSize: $0, drawings: currentDrawings)
		}
	}
	
	private func image(canvasSize: CGSize, drawings: [SignatureDrawing]) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: canvasSize)
		return renderer.image { ctx in
			drawings.forEach { drawing in
				ctx.cgContext.beginPath()
				let points = drawing.points
				if points.count > 1 {
					for idx in 0..<points.count-1 {
						let current = points[idx]
						let next = points[idx+1]
						ctx.cgContext.move(to: current)
						ctx.cgContext.addLine(to: next)
					}
				}
				ctx.cgContext.closePath()
			}
		}
	}
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
