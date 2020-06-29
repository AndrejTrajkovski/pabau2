import SwiftUI
import ComposableArchitecture

public let injectablesCanvasReducer = Reducer<InjectablesCanvasState, InjectablesCanvasAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .didTapOnCanvas(let point):
		let newInj = Injection(units: state.chosenInjectable.increment,
													 position: point)
		state.injections.append(newInj)
		state.activeInjection = newInj
	case .didTapOnInjection(let injection, let idx):
		if state.activeInjection == injection {
			state.injections[idx].units += state.chosenInjectable.increment
			state.activeInjection = state.injections[idx]
		} else {
			state.activeInjection = injection
		}
	case .marker(idx: let idx, action: let action):
		switch action {
		case .didSelectInjection(let injection):
			state.activeInjection = injection
			state.injections[idx] = injection
		case .didDragToPosition(let point):
			state.injections[idx].position = point
		}
	}
	return .none
}

public struct InjectablesCanvasState: Equatable {
	var allInjectables: [Injectable]
	var injections: IdentifiedArrayOf<InjectionsByInjectable>
	var activeInjection: Injection?
	var chosenInjectable: Injectable
	
	var markers: [InjectableMarkerState] {
		get {
			self.injections.map {
				return ($0.injections, $0.injectableId)
			}.flatMap {
				$0.
			}
		}
		set {
			
			self.injections = newValue.map { $0.injection }
			self.activeInjection = newValue.first?.activeInjection
		}
	}
}

public enum InjectablesCanvasAction: Equatable {
	case didTapOnCanvas(CGPoint)
	case didTapOnInjection(Injection, index: Int)
	case marker(idx: Int, action: MarkerAction)
}

struct InjectablesCanvas: View {
	let size: CGSize
	let store: Store<InjectablesCanvasState, InjectablesCanvasAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			ZStack(alignment: .topLeading) {
				TappableView { location in
					viewStore.send(.didTapOnCanvas(location))
				}
				.background(Color.clear)
				ForEachStore(self.store.scope(state: { $0.markers },
																			action: InjectablesCanvasAction.marker(idx: action:)),
										 content: {
											InjectableMarker(store: $0,
																			 imageSize: self.size)
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

public enum MarkerAction: Equatable {
	case didSelectInjection(Injection)
	case didDragToPosition(CGPoint)//self.injection.position = calculatedPos
}

struct InjectableMarkerState: Identifiable {
	var id: UUID { injection.id }
	var injection: Injection
	var isActive: Bool
	let injectable: Injectable
}

struct InjectableMarker: View {
	let store: Store<InjectableMarkerState, MarkerAction>
	private static let markerSize = CGSize.init(width: 50, height: 50)
	let imageSize: CGSize

	struct State: Equatable {
		let injection: Injection
		let isActive: Bool
		let color: Color
		let units: String
		let offset: CGSize
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			InjectableMarkerSimple(
				increment: viewStore.state.units,
				color: viewStore.state.color
			)
				.frame(width: Self.markerSize.width,
						 height: Self.markerSize.height,
						 alignment: .center)
				.onTapGesture {
						viewStore.send(.didSelectInjection(viewStore.state.injection))
				}
			.gesture(DragGesture().onChanged({ value in
				let calculatedPos =
					CGPoint(x: viewStore.state.injection.position.x + value.translation.width,
									y: viewStore.state.injection.position.y + value.translation.height)
				if calculatedPos.x > 0 &&
					calculatedPos.y > 0 &&
					calculatedPos.x + Self.markerSize.width < self.imageSize.width &&
					calculatedPos.y + Self.markerSize.height < self.imageSize.height {
					viewStore.send(.didDragToPosition(calculatedPos))
				}
			}))
				.offset(viewStore.state.offset)
		}
	}
}

struct InjectableMarkerSimple: View {
	let increment: String
	let color: Color
	
	var body: some View {
		ZStack {
			color
			Text(increment)
				.foregroundColor(.white)
				.font(.bold10)
		}
	}
}


extension InjectableMarker.State {
	init (state: InjectableMarkerState) {
		self.injection = state.injection
		self.isActive = state.isActive
		self.color = self.isActive ? Color.black : state.injectable.color
		self.units = String(state.injection.units)
		self.offset = CGSize(width: state.injection.position.x,
												 height: state.injection.position.y)
	}
}
