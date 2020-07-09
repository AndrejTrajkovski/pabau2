import SwiftUI
import ComposableArchitecture

public let injectablesCanvasReducer = Reducer<InjectablesCanvasState, InjectablesCanvasAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .didTapOnCanvas(let point):
		let injCenter = CGPoint(x: point.x - InjectableMarker.markerSize.width / 2,
														y: point.y - InjectableMarker.markerSize.height / 2)
		let units = state.allInjectables[id: state.chosenInjectableId]!.runningIncrement
		let newInj = Injection(units: units,
													 position: injCenter,
													 injectableId: state.chosenInjectableId)
		if var injections = state.photoInjections[state.chosenInjectableId] {
			injections.append(newInj)
			state.photoInjections[state.chosenInjectableId] = injections
		} else {
			state.photoInjections[state.chosenInjectableId] = [newInj]
		}
		state.chosenInjectionId = newInj.id
	case .injectable(let injectableId, let markerAction):
		switch markerAction {
		case .didTouchMarker(idx: let idx, action: let action):
				switch action {
				case .didSelectInjectionId(let injectionId):
					state.chosenInjectionId = injectionId
					state.chosenInjectableId = injectableId
				case .didDragToPosition(let point):
					state.photoInjections[injectableId]?[idx].position = point
				}
			}
	}
	return .none
}

public struct InjectablesCanvasState: Equatable {
	var allInjectables: IdentifiedArrayOf<Injectable>
	var photoInjections: [InjectableId: [Injection]]
	var chosenInjectableId: InjectableId
	var chosenInjectionId: UUID?
}

public enum InjectablesCanvasAction: Equatable {
	case didTapOnCanvas(CGPoint)
	case injectable(injectableId: InjectableId, action: MarkerInjectionAction)
}

struct InjectablesCanvas: View {
	let size: CGSize
	let store: Store<InjectablesCanvasState, InjectablesCanvasAction>
	struct State: Equatable {
		let allInjectables: IdentifiedArrayOf<Injectable>
		let chosenInjectionId: UUID?
//		let injectable: Injectable
		init(state: InjectablesCanvasState) {
			self.chosenInjectionId = state.chosenInjectionId
			self.allInjectables = state.allInjectables
//			self.injectable = state.allInjectables[id: state.chosenInjectableId]!
		}
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			ZStack(alignment: .topLeading) {
				TappableView { location in
					viewStore.send(.didTapOnCanvas(location))
				}
				.background(Color.clear)
				ForEachStore(self.store.scope(
					state: { canvasState in
						let markers = canvasState.photoInjections.mapValues { values in
							values.map { injection in
								InjectableMarkerState(injection: injection,
																			isActive: injection.id == viewStore.chosenInjectionId,
																			injectable: viewStore.state.allInjectables[id: injection.injectableId]!)
							}
						}
						return IdentifiedArray.init(markers, id: \.key)
				}, action: InjectablesCanvasAction.injectable(injectableId: action:)),
				content: { (injectionsStore: Store<(key: Int, value: [InjectableMarkerState]), MarkerInjectionAction>) in
					InjectionsByInjectable(store: injectionsStore,
																 imageSize: self.size)
				})
			}
		}
	}
}

public enum MarkerInjectionAction: Equatable {
	case didTouchMarker(idx: Int, action: MarkerAction)
}

struct InjectionsByInjectable: View {
	let store: Store<(key: Int, value: [InjectableMarkerState]), MarkerInjectionAction>
	let imageSize: CGSize
	var body: some View {
		ForEachStore(self.store.scope(
			state: { $0.value },
			action: { arg1, arg2 in
				MarkerInjectionAction.didTouchMarker(idx: arg1, action: arg2)
		}
		), content: { arg in
			InjectableMarker(store: arg,
											 imageSize: self.imageSize)
		})
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
	case didSelectInjectionId(UUID)
	case didDragToPosition(CGPoint)//self.injection.position = calculatedPos
}

struct InjectableMarkerState: Identifiable, Equatable {
	var id: UUID { injection.id }
	var injection: Injection
	var isActive: Bool
	let injectable: Injectable
}

struct InjectableMarker: View {
	let store: Store<InjectableMarkerState, MarkerAction>
	@ObservedObject var viewStore: ViewStore<ViewState, MarkerAction>
	public static let markerSize = CGSize.init(width: 44, height: 44)
	let imageSize: CGSize
	@State var offset: CGSize
	
	init(store: Store<InjectableMarkerState, MarkerAction>,
			 imageSize: CGSize) {
		self.store = store
		let viewStore = ViewStore(store.scope(state: ViewState.init(state:)), removeDuplicates: { lhs, rhs in
			lhs.id == rhs.id
		})
		self.viewStore = viewStore
		self.imageSize = imageSize
		self._offset = State.init(initialValue: viewStore.offset)
	}

	struct ViewState: Equatable {
		let id: UUID
		let isActive: Bool
		let color: Color
		let units: String
		let offset: CGSize
	}

	var body: some View {
//		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			InjectableMarkerSimple(
				increment: self.viewStore.state.units,
				color: self.viewStore.state.color,
				isActive: self.viewStore.state.isActive
			)
				.frame(width: Self.markerSize.width,
						 height: Self.markerSize.height,
						 alignment: .center)
				.onTapGesture {
					self.viewStore.send(.didSelectInjectionId(self.viewStore.state.id))
				}
			.gesture(
				DragGesture().onChanged({ value in
					let calculatedPos =
						CGPoint(x: self.offset.width + value.translation.width,
										y: self.offset.height + value.translation.height)
					if calculatedPos.x > 0 &&
						calculatedPos.y > 0 &&
						calculatedPos.x + Self.markerSize.width < self.imageSize.width &&
						calculatedPos.y + Self.markerSize.height < self.imageSize.height {
						self.offset = CGSize(width: calculatedPos.x, height: calculatedPos.y)
					}
				}
				).onEnded { value in
					let calculatedPos =
					CGPoint(x: self.offset.width + value.translation.width,
										y: self.offset.height + value.translation.height)
					if calculatedPos.x > 0 &&
						calculatedPos.y > 0 &&
						calculatedPos.x + Self.markerSize.width < self.imageSize.width &&
						calculatedPos.y + Self.markerSize.height < self.imageSize.height {
						self.viewStore.send(.didDragToPosition(calculatedPos))
					}
				}
			)
				.offset(self.offset)
//		}
	}
}

struct InjectableMarkerSimple: View {
	let increment: String
	let color: Color
	let isActive: Bool
	var body: some View {
		ZStack {
			Circle()
			.overlay(
				Group {
					if isActive {
						Circle()
							.stroke(Color.white, lineWidth: 2)
					}
				}
			).foregroundColor(color)
			Text(increment)
				.foregroundColor(.white)
				.font(.bold10)
		}
	}
}

extension Shape {
	/// fills and strokes a shape
	public func fill<S:ShapeStyle>(
		_ fillContent: S,
		stroke       : StrokeStyle
	) -> some View {
		ZStack {
			self.fill(fillContent)
			self.stroke(style:stroke)
		}
	}
}

extension InjectableMarker.ViewState {
	init (state: InjectableMarkerState) {
		self.id = state.injection.id
		self.isActive = state.isActive
		self.color = state.injectable.color
		self.units = String(state.injection.units)
		self.offset = CGSize(width: state.injection.position.x,
												 height: state.injection.position.y)
	}
}
