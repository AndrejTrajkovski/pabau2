import SwiftUI
import ComposableArchitecture
import PencilKit
import Combine
import Model
import Util

enum CanvasMode: Equatable {
	case drawing
	case injectables
}

func draw(injectionSize: CGSize,
		  widthToHeight: CGFloat,
          injection: Injection) {
    
    let colorInjection = Injectable.injectables().filter { $0.id == injection.injectableId }.first?.color
    let injectableMarkerPlain = InjectableMarkerPlain(wToHRatio: InjectableMarker.MarkerSizes.wToHRatio,
                                                      color: colorInjection ?? .white,
                                                      isActive: false,
                                                      increment: "\(injection.units)")
    
    let contentView: UIView = UIView(frame: CGRect(x: injection.position.x,
                                                   y: injection.position.y,
                                                   width: injectionSize.width,
                                                   height: injectionSize.height))
    
    let child = UIHostingController(rootView: injectableMarkerPlain)
    contentView.addSubview(child.view)
    child.view.frame = contentView.bounds
    child.view.backgroundColor = .clear
    
    contentView.drawHierarchy(in: contentView.frame, afterScreenUpdates: true)
}

let singlePhotoEditReducer: Reducer<SinglePhotoEditState, SinglePhotoEditAction, FormEnvironment> = .combine (
    .init { state, action, _ in
        if case .onChangePhotoSize(let size) = action {
            state.photo.canvasSize = size
        }
        return .none
    },
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
    var loadingState: LoadingState = .initial
    let isAlertActive: Bool
    
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
            CanvasViewState(photoId: self.photo.id,
                            drawing: self.photo.drawing,
                            activeCanvas: self.activeCanvas,
                            isDeletePhotoAlertActive: self.isAlertActive)
		}
		set {
            self.photo.drawing = newValue.drawing
            self.activeCanvas = newValue.activeCanvas
		}
	}
}

public enum SinglePhotoEditAction: Equatable {
	case photoAndCanvas(PhotoAndCanvasAction)
	case injectables(InjectablesAction)
    case updateImageInjectables(UIImage)
    case onChangePhotoSize(CGSize)
    case savePhotos
}

struct SinglePhotoEdit: View {

//    @State var photoSize: CGSize = .zero
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
        let canvasSize: CGSize
		init (state: SinglePhotoEditState) {
			let isInjectablesActive = state.activeCanvas == CanvasMode.injectables ? true : false
            if state.isAlertActive {
                self.injectablesZIndex = 1.0
                self.drawingCanvasZIndex = 0.0
            } else if isInjectablesActive {
				self.injectablesZIndex = 1.0
				self.drawingCanvasZIndex = 0.0
			} else {
				self.injectablesZIndex = 0.0
				self.drawingCanvasZIndex = 1.0
			}
            
			self.isInjectablesDisabled = !isInjectablesActive
			self.isDrawingDisabled = isInjectablesActive || state.isAlertActive
			self.isChooseInjectablesActive = state.isChooseInjectablesActive
            self.canvasSize = state.photo.canvasSize
		}
	}
    
    var body: some View {
        ZStack {
            PhotoParent(
                store: self.store.scope(state: { $0.photo }).actionless,
                viewStore.binding(
                    get: { $0.canvasSize },
                    send: { .onChangePhotoSize($0) })
            )
            IfLetStore(self.store.scope(
                        state: { $0.injectables.canvas },
                        action: { .injectables(InjectablesAction.canvas($0))}),
                       then: {
                        InjectablesCanvas(size: viewStore.canvasSize, store: $0)
                            .frame(width: viewStore.canvasSize.width,
                                   height: viewStore.canvasSize.height)
                            .disabled(viewStore.state.isInjectablesDisabled)
                            .zIndex(viewStore.state.injectablesZIndex)
                       }, else: { Spacer() }
            )
            CanvasView(store:
                        self.store.scope(
                            state: { $0.canvasState },
                            action: { .photoAndCanvas($0) })
            )
            .disabled(viewStore.state.isDrawingDisabled)
            .frame(width: viewStore.canvasSize.width,
                   height: viewStore.canvasSize.height)
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
