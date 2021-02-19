import CoreGraphics
import Foundation
import SwiftUI
import Model
import Util
import ComposableArchitecture
import SDWebImageSwiftUI
//for creating Image: https://www.hackingwithswift.com/read/27/3/drawing-into-a-core-graphics-context-with-uigraphicsimagerenderer

let signatureFieldReducer: Reducer<SignatureState, SignatureAction, FormEnvironment> = .init { state, action, env in
	switch action {
	case .update(let signature):
		state = signature
	}
	return .none
}

public enum SignatureAction: Equatable {
	case update(SignatureState)
}

struct SignatureField: View {
	@State var isSigning: Bool = false
	@Binding var signature: SignatureState
	let title: String

	init (signature: Binding<SignatureState>, title: String) {
		self._signature = signature
		self.title = title
	}

	var body: some View {
		print("isSigning \(isSigning)")
		return Group {
			if isSigning {
				DrawingPad(drawings: $signature.drawings)
					.disabled(true)
			} else if signature.drawings.isEmpty {
				TapToSign(isSigning: $isSigning)
			} else {
				SignedComponent(signature: $signature, onResign: {
					self.isSigning = true
				})
			}
		}.fullScreenCover(isPresented: $isSigning) {
			SigningComponent(title: title,
							 onCancel: { isSigning = false },
							 onDone: {
								isSigning = false
								signature.drawings = $0
							 })
		}
	}
}

struct SignedComponent: View {
	var baseUrl: String {
		return "https://crm.pabau.com"
//		guard let encoded = UserDefaults.standard.value(forKey: "logged_in_user") as? Data else { return "" }
//		return JSONDecoder().decode(User, from: encoded).baseUrl
	}
	@Binding var signature: SignatureState
	let onResign: () -> Void

	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text(Texts.resign)
					.font(.regular16).foregroundColor(.blue2)
					.onTapGesture(perform: onResign)
			}
			if let url = signature.signatureUrl {
				WebImage(url: URL(string: baseUrl + url))
					.resizable()
					.placeholder(Image("ico-journey-tap-to-sign"))
					.frame(height: 145)
			} else {
				DrawingPad(drawings: $signature.drawings)
					.disabled(true)
			}
		}
	}
}

struct SigningComponent: View {
	let title: String
	@State private var drawings: [SignatureDrawing] = []
	let onCancel: () -> Void
	let onDone: ([SignatureDrawing]) -> Void
	var body: some View {
		VStack(spacing: 32.0) {
			Text(title).font(.largeTitle)
			DrawingPad(drawings: $drawings)
			HStack {
				SecondaryButton(Texts.cancel, onCancel)
				PrimaryButton(Texts.done,
							  isDisabled: drawings.isEmpty) {
					self.onDone(self.drawings)
				}
				.disabled(drawings.isEmpty)
			}.padding()
		}
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
		GeometryReaderPatch { geometry in
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
