import CoreGraphics
import Foundation
import SwiftUI
import Model
import Util
//for creating Image: https://www.hackingwithswift.com/read/27/3/drawing-into-a-core-graphics-context-with-uigraphicsimagerenderer

enum SignatureState {
	case notSigned
	case signed
}

struct SignatureField: View {
	@State private var isSigning: Bool
	@Binding var signature: Signature
	var signingState: SignatureState {
		signature.drawings.isEmpty ? .notSigned : .signed
	}
	
	init (signature: Binding<Signature>) {
		self._signature = signature
		self._isSigning = State.init(initialValue: false)
	}
	
	var body: some View {
		Group {
			if self.isSigning {
				DrawingPad(drawings: $signature.drawings)
					.disabled(true)
					.sheet(isPresented: .constant(true)) {
						SigningComponent(isActive: self.$isSigning,
														 onDone: { self.signature = $0 })
				}
			} else if self.signingState == .notSigned {
				TapToSign(isSigning: $isSigning)
			} else {
				SignedComponent(isSigning: $isSigning,
												signature: $signature)
			}
		}
	}
}

struct SignedComponent: View {
	@Binding var isSigning: Bool
	@Binding var signature: Signature
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text(Texts.resign)
					.font(.regular16).foregroundColor(.blue2)
					.onTapGesture {
						self.isSigning = true
				}
			}
			DrawingPad(drawings: $signature.drawings)
				.disabled(true)
		}
	}
}

struct SigningComponent: View {
	@State private var signature: Signature = Signature()
	@Binding var isActive: Bool
	let onDone: (Signature) -> Void
	var body: some View {
		VStack {
			DrawingPad(drawings: $signature.drawings)
								.disabled(false)
			HStack {
				PabauButton(btnTxt: Texts.cancel,
										style: .white) {
					self.isActive = false
				}
				PabauButton(btnTxt: Texts.done,
										style: .blue) {
					self.isActive = false
					self.onDone(self.signature)
				}
				.disabled(signature.drawings.isEmpty)
			}.fixedSize(horizontal: true, vertical: false)
		}.fixedSize(horizontal: false, vertical: true)
	}
}

struct TapToSign: View {
	@Binding var isSigning: Bool
	var body: some View {
		Image("ico-journey-tap-to-sign")
		.resizable()
		.frame(width: 137, height: 137)
		.onTapGesture {
			self.isSigning = true
		}
	}
}

struct DrawingPad: View {
	@State private var currentDrawing = SignatureDrawing()
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
		.background(Color(hex: "F6F6F6"))
		.border(Color(hex: "DADADA"), width: 1)
		.frame(height: 200)
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
