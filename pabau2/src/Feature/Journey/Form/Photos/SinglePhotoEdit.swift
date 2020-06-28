import SwiftUI
import ComposableArchitecture

enum ActiveCanvas {
	case drawing
	case injectables
}

let singlePhotoEditReducer: Reducer<SinglePhotoEditState, SinglePhotoEditAction, JourneyEnvironment> = .combine (
	injectablesCanvasReducer.optional.pullback(
		state: \SinglePhotoEditState.injectablesCanvas,
		action: /SinglePhotoEditAction.injectablesCanvas,
		environment: { $0 }),
	activeInjectableReducer.optional.pullback(
		state: \SinglePhotoEditState.activeInjectable,
		action: /SinglePhotoEditAction.activeInjectable,
		environment: { $0 }),
	photoAndCanvasReducer.pullback(
		state: \SinglePhotoEditState.photo,
		action: /SinglePhotoEditAction.photoAndCanvas,
		environment: { $0 })
)

struct SinglePhotoEditState: Equatable {
	var activeCanvas: ActiveCanvas
	var photo: PhotoViewModel
	var chosenIncrement: Double
	var chosenInjectable: Injectable?

	var activeInjectable: ActiveInjectableState? {
		get {
			guard let chosenInjectable = chosenInjectable else { return nil }
			return ActiveInjectableState(photoInjections: photo.injections,
														chosenIncrement: chosenIncrement,
														chosenInjectable: chosenInjectable,
														chosenInjection: photo.activeInjection)
		}
		set {
			self.chosenInjectable = newValue?.chosenInjectable
			guard let newValue = newValue else { return  }
			self.photo.injections = newValue.photoInjections
			self.chosenIncrement = newValue.chosenIncrement
			self.photo.activeInjection = newValue.chosenInjection
		}
	}
	
	var injectablesCanvas: InjectablesCanvasState? {
		get {
			chosenInjectable.map {
				InjectablesCanvasState(
					photo: photo,
					chosenIncrement: chosenIncrement,
					chosenInjectable: $0)
			}
		}
		set {
			self.chosenInjectable = newValue?.chosenInjectable
			guard let newValue = newValue else { return }
			self.photo = newValue.photo
			self.chosenIncrement = newValue.chosenIncrement
		}
	}
}

public enum SinglePhotoEditAction: Equatable {
	case photoAndCanvas(PhotoAndCanvasAction)
	case injectablesCanvas(InjectablesCanvasAction)
	case activeInjectable(ActiveInjectableAction)
}

struct SinglePhotoEdit: View {
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
			let isInjectablesActive = state.chosenInjectable != nil ? true : false
			if isInjectablesActive {
				self.injectablesZIndex = 1.0
				self.drawingCanvasZIndex = 0.0
			} else {
				self.injectablesZIndex = 0.0
				self.drawingCanvasZIndex = 1.0
			}
			self.isDrawingDisabled = !isInjectablesActive
		}
	}
	
	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			VStack {
				IfLetStore(self.store.scope(
					state: { $0.activeInjectable },
					action: { .activeInjectable($0) }
					),
									 then: {
										ActiveInjectable(store: $0)
					}
				)
				ZStack {
					IfLetStore(self.store.scope(
						state: { $0.injectablesCanvas },
						action: { .injectablesCanvas($0) }),
										 then: {
											InjectablesCanvas(size: self.photoSize,
																				store: $0)
												.frame(width: self.photoSize.width,
															 height: self.photoSize.height)
												.background(Color.red.opacity(0.4))
												.zIndex(viewStore.state.injectablesZIndex)
					})
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
}
