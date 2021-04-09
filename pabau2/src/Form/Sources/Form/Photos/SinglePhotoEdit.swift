import SwiftUI
import ComposableArchitecture
import PencilKit

enum CanvasMode: Equatable {
	case drawing
	case injectables
}

let singlePhotoEditReducer: Reducer<SinglePhotoEditState, SinglePhotoEditAction, FormEnvironment> = .combine (
	injectablesContainerReducer.pullback(
		state: \SinglePhotoEditState.injectables,
		action: /SinglePhotoEditAction.injectables,
		environment: { $0 }),
	photoAndCanvasReducer.pullback(
		state: \SinglePhotoEditState.photo,
		action: /SinglePhotoEditAction.photoAndCanvas,
		environment: { $0 }),
    .init { state, action, _ in
        switch action {
        case .saveDrawings:
            let size = state.photoSize
            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { (ctx) in
                if case .saved(let savedPhoto) = state.photo.basePhoto {
                    let photoImage = UIImage(contentsOfFile: savedPhoto.normalSizePhoto!)
                    photoImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                }
                
                state.imageInjectable.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                state.photo.drawing.image(from: CGRect(x: 0, y: 0, width: size.width, height: size.height), scale: 1)
                    .draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                
            }            
        case .updateImageInjectables(let image):
            state.imageInjectable = image
        case .onChangePhotoSize(let size):
            state.photoSize = size
        default:
            break
        }
        return .none
    }
)

struct SinglePhotoEditState: Equatable {
	var activeCanvas: CanvasMode
	var photo: PhotoViewModel
	var allInjectables: IdentifiedArrayOf<Injectable>
	var isChooseInjectablesActive: Bool
	var chosenInjectatbleId: InjectableId?
    var imageInjectable: UIImage
    var photoSize: CGSize = .zero

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
    case saveDrawings
    case updateImageInjectables(UIImage)
    case onChangePhotoSize(CGSize)
}

struct SinglePhotoEdit: View {

	@State var photoSize: CGSize = .zero
	let store: Store<SinglePhotoEditState, SinglePhotoEditAction>
	@ObservedObject var viewStore: ViewStore<ViewState, SinglePhotoEditAction>
	public init(store: Store<SinglePhotoEditState, SinglePhotoEditAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: ViewState.init(state:)))
	}
    
    @State private var didChangeInjection: Bool = false

	struct ViewState: Equatable {
		let injectablesZIndex: Double
		let drawingCanvasZIndex: Double
		let isDrawingDisabled: Bool
		let isChooseInjectablesActive: Bool
		let isInjectablesDisabled: Bool
        let imageInjectable: UIImage
        let photoSize: CGSize
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
			self.isChooseInjectablesActive = state.isChooseInjectablesActive
            self.imageInjectable = state.imageInjectable
            self.photoSize = state.photoSize
		}
	}

	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			ZStack {
				PhotoParent(
					store: self.store.scope(state: { $0.photo }).actionless,
					self.$photoSize
                )
                .onPreferenceChange(PhotoSize.self) { size in
                    if size != .zero {
                        viewStore.send(.onChangePhotoSize(size))
                    }
                }
                
				IfLetStore(self.store.scope(
					state: { $0.injectables.canvas },
					action: { .injectables(InjectablesAction.canvas($0))}),
									 then: {
                                        InjectablesCanvas(didChange: $didChangeInjection, size: self.photoSize, store: $0)
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
            .onChange(of: didChangeInjection, perform: { _ in
                let snapshot = self.viewSnapshot()
                viewStore.send(.updateImageInjectables(snapshot))
            })
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


extension View {
   public func viewSnapshot() -> UIImage {
            let controller = UIHostingController(rootView: self)
            let view = controller.view

            let targetSize = controller.view.intrinsicContentSize
            view?.bounds = CGRect(origin: .zero, size: targetSize)
            view?.backgroundColor = .clear

            let renderer = UIGraphicsImageRenderer(size: targetSize)

            return renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
}
