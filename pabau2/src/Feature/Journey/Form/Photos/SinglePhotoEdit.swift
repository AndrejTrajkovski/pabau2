import SwiftUI
import ComposableArchitecture
import PencilKit

enum CanvasMode: Equatable {
	case drawing
	case injectables
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
	var allInjectables: IdentifiedArrayOf<Injectable>
	var isChooseInjectablesActive: Bool
	var chosenInjectatbleId: InjectableId?

	var injectables: InjectablesState {
		get {
			InjectablesState(
				allInjectables: self.allInjectables,
				photoInjections: self.photo.injections,
				isChooseInjectablesActive: self.isChooseInjectablesActive,
				chosenInjectableId: self.chosenInjectatbleId,
				chosenInjectionId: self.photo.chosenInjectionId)
		}
		set {
			self.allInjectables = newValue.allInjectables
			self.photo.injections = newValue.photoInjections
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.chosenInjectatbleId = newValue.chosenInjectableId
			self.photo.chosenInjectionId = newValue.chosenInjectionId
		}
	}

	var canvasState: CanvasViewState {
		get {
			CanvasViewState(photo: self.photo,
											isDisabled: self.activeCanvas != .drawing)
		}
		set {
			self.photo = newValue.photo
		}
	}
}

public enum SinglePhotoEditAction: Equatable {
	case photoAndCanvas(PhotoAndCanvasAction)
	case injectables(InjectablesAction)
}

struct SinglePhotoEdit: View {
	
	@State var photoSize: CGSize = .zero
	let store: Store<SinglePhotoEditState, SinglePhotoEditAction>
	@ObservedObject var viewStore: ViewStore<ViewState, SinglePhotoEditAction>
	public init(store: Store<SinglePhotoEditState, SinglePhotoEditAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: ViewState.init(state:)))
	}

	struct ViewState: Equatable {
		let injectablesZIndex: Double
		let drawingCanvasZIndex: Double
		let isDrawingDisabled: Bool
		let isChooseInjectablesActive: Bool
		let isInjectablesDisabled: Bool
		
		init (state: SinglePhotoEditState) {
			let isInjectablesActive = state.activeCanvas == CanvasMode.injectables ? true : false
			if isInjectablesActive {
				self.injectablesZIndex = 1.0
				self.drawingCanvasZIndex = 0.0
			} else {
				self.injectablesZIndex = 0.0
				self.drawingCanvasZIndex = 1.0
			}
			self.isInjectablesDisabled = !isInjectablesActive
			self.isDrawingDisabled = isInjectablesActive
			print("isDrawingDisabled \(isInjectablesActive)")
			self.isChooseInjectablesActive = state.isChooseInjectablesActive
		}
	}

	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			ZStack {
				PhotoParent(
					store: self.store.scope(state: { $0.photo }).actionless,
					self.$photoSize
				)
				IfLetStore(self.store.scope(
					state: { $0.injectables.canvas },
					action: { .injectables(InjectablesAction.canvas($0))}),
									 then: {
										InjectablesCanvas(size: self.photoSize, store: $0)
											.frame(width: self.photoSize.width,
														 height: self.photoSize.height)
											.disabled(viewStore.state.isInjectablesDisabled)
											.zIndex(viewStore.state.injectablesZIndex)
				}, else: Spacer()
				)
				CanvasView(store:
					self.store.scope(
						state: { $0.canvasState },
						action: { .photoAndCanvas($0) })
				)
					.disabled(viewStore.state.isDrawingDisabled)
					.frame(width: self.photoSize.width,
								 height: self.photoSize.height)
					.zIndex(viewStore.state.drawingCanvasZIndex)
			}
			.sheet(isPresented: viewStore.binding(
				get: { $0.isChooseInjectablesActive },
				send: { _ in .injectables(.chooseInjectables(.onDismissChooseInjectables)) }
				), content: {
					ChooseInjectable(store:
						self.store.scope(state: { $0.injectables.chooseInjectables },
														 action: { .injectables(.chooseInjectables($0)) })
					)
			})
		}.debug("SinglePhotoEdit")
	}
}
