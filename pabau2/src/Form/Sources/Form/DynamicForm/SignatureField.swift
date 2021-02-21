import CoreGraphics
import Foundation
import SwiftUI
import Model
import Util
import ComposableArchitecture
import SDWebImageSwiftUI
//for creating Image: https://www.hackingwithswift.com/read/27/3/drawing-into-a-core-graphics-context-with-uigraphicsimagerenderer

let signatureFieldReducer: Reducer<SignatureState, SignatureAction, Any> =
	.combine (
//		signingComponentReducer.optional.pullback(
//			state: \SignatureState.signing,
//			action: /SignatureAction.signing,
//			environment: { $0 }
//		),
		.init { state, action, _ in
			switch action {
			case .tapToResign, .tapToSign:
				state.isSigning = true
			case .signing(.done(let drawings)):
				state.currentDrawings = drawings
				state.isSigning = false
			case .signing(.cancel):
				state.isSigning = false
			}
			return .none
		}
	)

public enum SignatureAction: Equatable {
	case tapToResign
	case tapToSign
	case signing(SigningComponentAction)
}

struct SignatureField: View {

	struct State: Equatable {
		let isSigningPresented: Bool
		let signed: SignedState?
		enum SignedState: Equatable {
			case url(String)
			case drawings([SignatureDrawing])
		}

		init(state: SignatureState) {
			self.isSigningPresented = state.isSigning
			if !state.currentDrawings.isEmpty {
				self.signed = .drawings(state.currentDrawings)
			} else if let signatureUrl = state.signatureUrl {
				self.signed = .url(signatureUrl)
			} else {
				self.signed = nil
			}
		}
	}

	let store: Store<SignatureState, SignatureAction>
	@ObservedObject var viewStore: ViewStore<State, SignatureAction>
	let title: String

	var baseUrl: String {
		return "https://crm.pabau.com"
		//		guard let encoded = UserDefaults.standard.value(forKey: "logged_in_user") as? Data else { return "" }
		//		return JSONDecoder().decode(User, from: encoded).baseUrl
	}

	init(store: Store<SignatureState, SignatureAction>,
		 title: String) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
		self.title = title
	}

	var body: some View {
		Group {
			switch viewStore.signed {
			case .url(let signatureUrl):
				SignedComponent(onResign: { viewStore.send(.tapToResign) },
								content: {
									WebImage(url: URL(string: baseUrl + signatureUrl))
										.resizable()
										.placeholder(Image("ico-journey-tap-to-sign"))
										.frame(height: 145)
								})
			case .drawings(let drawings):
				SignedComponent(onResign: { viewStore.send(.tapToResign) },
								content: {
									DrawingPad(currentDrawing: .constant(SignatureDrawing()),
											   drawings: .constant(drawings))
										.disabled(true)
								})
			case .none:
				TapToSign(onTap: { viewStore.send(.tapToSign) })
			}
		}.fullScreenCover(isPresented: .constant(viewStore.isSigningPresented)) {
			SigningComponent(store: store.scope(state: { _ in EmptyEquatable() },
												action: SignatureAction.signing),
							 title: title)
//			IfLetStore(store.scope(state: { $0.signing },
//								   action: SignatureAction.signing),
//					   then: { SigningComponent.init(store: $0, title: title) })
		}
	}
}

struct SignedComponent<Content: View>: View {

	let onResign: () -> Void
	let content: () -> Content

	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text(Texts.resign)
					.font(.regular16).foregroundColor(.blue2)
					.onTapGesture(perform: onResign)
			}
			content()
		}
	}
}

public enum SigningComponentAction: Equatable {
	case done([SignatureDrawing])
	case cancel
}

struct EmptyEquatable: Equatable { }

struct SigningComponent: View {

	let store: Store<EmptyEquatable, SigningComponentAction>
	@ObservedObject var viewStore: ViewStore<EmptyEquatable, SigningComponentAction>
	let title: String
	@State var currentDrawing = SignatureDrawing()
	@State var drawings = [SignatureDrawing]()
	
	init(store: Store<EmptyEquatable, SigningComponentAction>,
		 title: String) {
		self.store = store
		self.viewStore = ViewStore(store)
		self.title = title
	}

	var body: some View {
		VStack(spacing: 32.0) {
			Text(title).font(.largeTitle)
			DrawingPad(currentDrawing: $currentDrawing,
					   drawings: $drawings)
			HStack {
				SecondaryButton(Texts.cancel,
								{ self.viewStore.send(.cancel) }
				)
				PrimaryButton(Texts.done,
							  isDisabled: drawings.isEmpty,
							  { self.viewStore.send(.done(drawings)) })
				//					self.onDone(self.drawings)
			}
		}.padding()
	}
}

struct TapToSign: View {
	let onTap: () -> Void
	var body: some View {
		Image("ico-journey-tap-to-sign")
		.resizable()
		.frame(width: 137, height: 137)
		.onTapGesture(perform: onTap)
	}
}

struct DrawingPad: View {
	
	@Binding var currentDrawing: SignatureDrawing
	@Binding var drawings: [SignatureDrawing]
	
	var body: some View {
		GeometryReaderPatch { geometry in
			Path { path in
				for drawing in drawings {
					self.add(drawing: drawing, toPath: &path)
				}
				self.add(drawing: currentDrawing, toPath: &path)
			}
			.stroke(lineWidth: 1.0)
			.background(Color(white: 0.95))
				.gesture(
					DragGesture(minimumDistance: 0.1)
						.onChanged({ (value) in
							let currentPoint = value.location
							if currentPoint.y >= 0 && currentPoint.y < geometry.size.height {
								currentDrawing.points.append(currentPoint)
							}
						})
						.onEnded({ _ in
							drawings.append(currentDrawing)
							currentDrawing = SignatureDrawing()
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
