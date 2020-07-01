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
	var allInjectables: IdentifiedArrayOf<Injectable>
	var isChooseInjectablesActive: Bool
	var chosenInjectableId: InjectableId?
	var chosenInjectionId: UUID?

	var injectables: InjectablesState {
		get {
			InjectablesState(
				allInjectables: self.allInjectables,
				photoInjections: self.photo.injections,
				isChooseInjectablesActive: self.isChooseInjectablesActive,
				chosenInjectableId: self.chosenInjectableId,
				chosenInjectionId: self.chosenInjectionId)
		}
		set {
			self.allInjectables = newValue.allInjectables
			self.photo.injections = newValue.photoInjections
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.chosenInjectableId = newValue.chosenInjectableId
			self.chosenInjectionId = newValue.chosenInjectionId
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
		let isChooseInjectablesActive: Bool
		let chosenInjectableId: InjectableId?
		let allInjectables: IdentifiedArrayOf<Injectable>
		let photoInjections: [InjectableId: [Injection]]
		let chosenInjectionId: UUID?
		
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
			self.isChooseInjectablesActive = state.isChooseInjectablesActive
			self.chosenInjectableId = state.chosenInjectableId
			self.allInjectables = state.allInjectables
			self.photoInjections = state.photo.injections
			self.chosenInjectionId = state.chosenInjectionId
		}
	}

	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			VStack {
				Spacer()
				ZStack {
					PhotoParent(
						store: self.store.scope(state: { $0.photo}).actionless,
						self.$photoSize
					)
					IfLetStore(self.store.scope(
						state: { $0.injectables.canvas },
						action: { .injectables(InjectablesAction.canvas($0))})
						, then: {
							InjectablesCanvas(size: self.photoSize, store: $0)
								.frame(width: self.photoSize.width,
											 height: self.photoSize.height)
								.zIndex(viewStore.state.injectablesZIndex)
					})
						.background(Color.red.opacity(0.4))
					CanvasView(viewStore: ViewStore(
						self.store.scope(
							state: { $0.photo },
							action: { .photoAndCanvas($0) })
						, removeDuplicates: { lhs, rhs in
						lhs.id == rhs.id
					}))
						.frame(width: self.photoSize.width,
									 height: self.photoSize.height)
						.disabled(viewStore.state.isDrawingDisabled)
						.zIndex(viewStore.state.drawingCanvasZIndex)
					.background(Color.green.opacity(0.4))
				}
				Spacer()
				Group {
					if viewStore.state.isDrawingDisabled {
						IfLetStore(self.store.scope(
							state: { $0.injectables.stepper },
							action: { .injectables(InjectablesAction.stepper($0))})
							, then: {
								InjectableStepper(store: $0)
									.padding()
						})
					} else {
						Color.clear
					}
				}.frame(height: self.footerHeight)
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
		}
	}
}
