import CoreGraphics
import Foundation
import SwiftUI
import Model
//for creating Image: https://www.hackingwithswift.com/read/27/3/drawing-into-a-core-graphics-context-with-uigraphicsimagerenderer
struct SignatureField: View {
	@Binding var signature: Signature
	@State private var currentDrawing = SignatureDrawing()
//	@State private var drawings = [SignatureDrawing]()

	var body: some View {
		VStack(alignment: .trailing) {
			Button("Resign") {
				self.signature.resetDrawings()
			}.font(.regular16).foregroundColor(.blue2)
			DrawingPad(currentDrawing: $currentDrawing,
								 drawings: $signature.drawings)
				.background(Color(hex: "F6F6F6"))
				.border(Color(hex: "DADADA"), width: 1)
				.frame(height: 200)
		}
	}
}

struct DrawingPad: View {
	@Binding var currentDrawing: SignatureDrawing
	@Binding var drawings: [SignatureDrawing]

	var body: some View {
		GeometryReader { geometry in
			Path { path in
				for drawing in self.drawings {
					self.add(drawing: drawing, toPath: &path)
				}
				self.add(drawing: self.currentDrawing, toPath: &path)
			}
			.stroke(lineWidth: 1.0)
			.background(Color(white: 0.95))
			.gesture(
				DragGesture(minimumDistance: 0.1)
					.onChanged({ (value) in
						let currentPoint = value.location
						if currentPoint.y >= 0
							&& currentPoint.y < geometry.size.height {
							self.currentDrawing.points.append(currentPoint)
						}
					})
					.onEnded({ _ in
						self.drawings.append(self.currentDrawing)
						self.currentDrawing = SignatureDrawing()
					})
			)
		}
		.frame(maxHeight: .infinity)
	}

	private func add(drawing: SignatureDrawing, toPath path: inout Path) {
		let points = drawing.points
		if points.count > 1 {
			for idx in 0..<points.count-1 {
				let current = points[idx]
				let next = points[idx+1]
				path.move(to: current)
				path.addLine(to: next)
			}
		}
	}
}
