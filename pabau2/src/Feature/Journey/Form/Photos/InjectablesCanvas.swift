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
	case .marker(id: let id, action: let action):
		switch action {
		case .didSelectInjection(let injection):
			state.activeInj
		case .didDragToPosition(let point)
			<#code#>
		}
	}
	return .none
}

public struct InjectablesCanvasState: Equatable {
	var allProducts: [Injectable]
	var photoInjections: [Injection]
	var chosenIncrement: Double
	var activeInjection: Injection?
	var activeInjectable: Injectable
	
	var markers: [InjectableMarkerState] {
		get {
			self.photoInjections.map {
				InjectableMarkerState.init(injection: $0,
																	 activeInjection: self.activeInjection)}
		}
		set {
			self.photoInjections = newValue.map { $0.injection }
			self.activeInjection = newValue.first?.activeInjection
		}
	}
}

public enum InjectablesCanvasAction: Equatable {
	case didTapOnCanvas(CGPoint)
	case didTapOnInjection(Injection, index: Int)
	case marker(id: Int, action: MarkerAction)
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
																 action: InjectablesCanvasAction.marker(id: action:)),
										 content: {
											InjectableMarker(store: $0,
																			 imageSize: self.size)
				})
//				ForEach(viewStore.state.photoInjections.indices, id: \.self) { idx in
//					InjectableMarker(imageSize: self.size,
//													 isActive: viewStore.state.photoInjections[idx] == viewStore.state.activeInjection,
//													 injection: self.$photoInjections[idx],
//													 onSelect: {
//														viewStore.send(.didTapOnInjection($0, index: idx))
//					})
//				}
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
	var activeInjection: Injection?
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
			ZStack {
				viewStore.state.color
				Text(viewStore.state.units)
					.foregroundColor(.white)
					.font(.bold10)
			}
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

extension InjectableMarker.State {
	init (state: InjectableMarkerState) {
		self.injection = state.injection
		self.isActive = state.injection == state.activeInjection
		self.color = self.isActive ? Color.black : state.injection.injectable.color
		self.units = String(state.injection.units)
		self.offset = CGSize(width: state.injection.position.x,
												 height: state.injection.position.y)
	}
}