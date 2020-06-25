import SwiftUI
import ComposableArchitecture

public let injectablesCanvasReducer = Reducer<InjectablesCanvasState, InjectablesCanvasAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .didTapOnCanvas(let point):
		let newInj = Injection(injectable: state.activeInjectable,
													 units: state.activeInjectable.increment,
													 position: point)
		state.photoInjections.append(newInj)
		state.activeInjection = newInj
	case .didTapOnInjection(let injection, let idx):
		if state.activeInjection == injection {
			state.photoInjections[idx].units += state.chosenIncrement
			state.activeInjection = state.photoInjections[idx]
		} else {
			state.activeInjection = injection
		}
	}
	return .none
}

public struct InjectablesCanvasState: Equatable {
	var allProducts: [Injectable]
	var photoInjections: [Injection]
	var chosenIncrement: Double
	var activeInjection: Injection
	var activeInjectable: Injectable
}

public enum InjectablesCanvasAction: Equatable {
	case didTapOnCanvas(CGPoint)
	case didTapOnInjection(Injection, index: Int)
}

struct InjectablesCanvas: View {
	let size: CGSize
	let store: Store<InjectablesCanvasState, InjectablesCanvasAction>
	@State var photoInjections: [Injection] = [
		Injection(injectable: JourneyMocks.injectables()[0],
							units: 0.2,
							position: CGPoint(x: 150, y: 150)),
		Injection(injectable: JourneyMocks.injectables()[1],
							units: 0.1,
							position: CGPoint(x: 50, y: 50)),
		Injection(injectable: JourneyMocks.injectables()[2],
							units: 0.3,
							position: CGPoint(x: 30, y: 90))
	]

	@State var activeInjectable: Injectable = JourneyMocks.injectables()[0]
	@State var chosenIncrement: Double = 0.25
	@State var activeInjection: Injection?

	var body: some View {
		ZStack(alignment: .topLeading) {
			TappableView { location in
				let newInj = Injection(injectable: self.activeInjectable,
															 units: self.activeInjectable.increment,
															 position: location)
				self.photoInjections.append(newInj)
				self.activeInjection = newInj
			}
			.background(Color.clear)
			ForEach(self.photoInjections.indices, id: \.self) { idx in
				InjectableMarker(imageSize: self.size,
												 isActive: self.photoInjections[idx] == self.activeInjection,
												 injection: self.$photoInjections[idx],
												 onSelect: {
													if self.activeInjection == $0 {
														self.photoInjections[idx].units += self.chosenIncrement
														self.activeInjection = self.photoInjections[idx]
													} else {
														self.activeInjection = $0
													}
				})
			}
		}
	}
}

struct TappableView: UIViewRepresentable {
	var tappedCallback: ((CGPoint) -> Void)

	func makeUIView(context: UIViewRepresentableContext<TappableView>) -> UIView {
		let view = UIView(frame: .zero)
		let gesture = UITapGestureRecognizer(target: context.coordinator,
																				 action: #selector(Coordinator.tapped))
		view.addGestureRecognizer(gesture)
		return view
	}

	class Coordinator: NSObject {
		var tappedCallback: ((CGPoint) -> Void)
		init(tappedCallback: @escaping ((CGPoint) -> Void)) {
			self.tappedCallback = tappedCallback
		}
		@objc func tapped(gesture: UITapGestureRecognizer) {
			let point = gesture.location(in: gesture.view)
			self.tappedCallback(point)
		}
	}

	func makeCoordinator() -> TappableView.Coordinator {
		return Coordinator(tappedCallback: self.tappedCallback)
	}

	func updateUIView(_ uiView: UIView,
										context: UIViewRepresentableContext<TappableView>) {
	}
}

struct InjectableMarker: View {
	private static let markerSize = CGSize.init(width: 50, height: 50)
	let imageSize: CGSize
	let isActive: Bool
	@Binding var injection: Injection
	let onSelect: (Injection) -> Void
	var body: some View {
			ZStack {
				Group {
					if self.isActive {
						Color.black
					} else {
						self.injection.injectable.color
					}
				}
				Text(String(self.injection.units))
					.foregroundColor(.white)
					.font(.bold10)
			}
			.frame(width: Self.markerSize.width,
						 height: Self.markerSize.height,
						 alignment: .center)
			.onTapGesture {
				self.onSelect(self.injection)
			}
			.gesture(DragGesture().onChanged({ value in
				let calculatedPos =
					CGPoint(x: self.injection.position.x + value.translation.width,
									y: self.injection.position.y + value.translation.height)
				if calculatedPos.x > 0 &&
					calculatedPos.y > 0 &&
					calculatedPos.x + Self.markerSize.width < self.imageSize.width &&
					calculatedPos.y + Self.markerSize.height < self.imageSize.height {
					self.injection.position = calculatedPos
				}
			}))
				.offset(CGSize(width: self.injection.position.x,
											 height: self.injection.position.y))
		}
}
