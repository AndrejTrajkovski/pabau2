import SwiftUI
import ComposableArchitecture
import PencilKit

enum CanvasMode: Equatable {
	case drawing
	case injectables
	case view
}

let singlePhotoEditReducer: Reducer<SinglePhotoEditState, SinglePhotoEditAction, JourneyEnvironment> = .combine (
	injectablesContainerReducer.pullback(
		state: \SinglePhotoEditState.injectables,
		action: /SinglePhotoEditAction.injectables,
		environment: { $0 }),
	photoAndCanvasReducer.pullback(
		state: \SinglePhotoEditState.photo,
		action: /SinglePhotoEditAction.photoAndCanvas,
		environment: { $0 })
)

struct SinglePhotoEditState: Equatable {
	var activeCanvas: CanvasMode
	var photo: PhotoViewModel
	var allInjectables: [Injectable]
	var isChooseInjectablesActive: Bool = false
	var stepper: InjectableStepperState?
	var canvas: InjectablesCanvasState?

	var injectables: InjectablesState {
		get {
			InjectablesState(
				allInjectables: self.allInjectables,
				photoInjections: self.photo.injections,
				isChooseInjectablesActive: self.isChooseInjectablesActive,
				stepper: self.stepper,
				canvas: self.canvas)
		}
		set {
			self.allInjectables = newValue.allInjectables
			self.photo.injections = newValue.photoInjections
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.stepper = newValue.stepper
			self.canvas = newValue.canvas
		}
	}
}

public enum SinglePhotoEditAction: Equatable {
	case photoAndCanvas(PhotoAndCanvasAction)
	case injectables(InjectablesAction)
}

struct SinglePhotoEdit: View {
	let footerHeight: CGFloat = 128.0
	@State var photoSize: CGSize = .zero
	let store: Store<SinglePhotoEditState, SinglePhotoEditAction>
	public init(store: Store<SinglePhotoEditState, SinglePhotoEditAction>) {
		self.store = store
	}

	struct ViewState: Equatable {
		let injectablesZIndex: Double
		let drawingCanvasZIndex: Double
		let isDrawingDisabled: Bool
	
		init (state: SinglePhotoEditState) {
			let isInjectablesActive = state.activeCanvas == CanvasMode.injectables ? true : false
			if isInjectablesActive {
				self.injectablesZIndex = 1.0
				self.drawingCanvasZIndex = 0.0
			} else {
				self.injectablesZIndex = 0.0
				self.drawingCanvasZIndex = 1.0
			}
			self.isDrawingDisabled = isInjectablesActive
		}
	}

	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			ZStack {
				InjectablesContainer(
					store: self.store.scope(
						state: { $0.injectables },
						action: { .injectables($0) }),
					photoSize: self.$photoSize,
					footerHeight: self.footerHeight
				)
					.background(Color.red.opacity(0.4))
					.zIndex(viewStore.state.injectablesZIndex)
				PhotoAndCanvas(store:
					self.store.scope(state: { $0.photo },
													 action: { .photoAndCanvas($0) }),
											 self.$photoSize
				)
					.disabled(viewStore.state.isDrawingDisabled)
					.zIndex(viewStore.state.drawingCanvasZIndex)
			}
		}
	}
}