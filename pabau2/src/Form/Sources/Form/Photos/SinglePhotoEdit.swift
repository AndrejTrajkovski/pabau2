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
	injectablesContainerReducer.pullback(
		state: \SinglePhotoEditState.injectables,
		action: /SinglePhotoEditAction.injectables,
		environment: { $0 }),
	photoAndCanvasReducer.pullback(
		state: \SinglePhotoEditState.photo,
		action: /SinglePhotoEditAction.photoAndCanvas,
        environment: { $0 }),
    .init { state, action, env in

        switch action {
        case .savePhotosResponse(let result):
            state.loadingState = .initial
            switch result {
            case .success(let voResponse):
                state.loadingState = .gotSuccess
            case .failure(let error):
                state.loadingState = .gotError(error)
            }
        case .cancelUpload:
            return .cancel(id: UploadPhotoId())
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
    var editingPhotoId: PhotoVariantId?
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
			CanvasViewState(photo: self.photo,
                            activeCanvas: self.activeCanvas,
                            isDeletePhotoAlertActive: self.isAlertActive)
		}
		set {
			self.photo = newValue.photo
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
    case savePhotosResponse(Result<VoidAPIResponse, RequestError>)
    case cancelUpload
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
        let loadingState: LoadingState
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
            self.loadingState = state.loadingState
		}
	}
    
    var body: some View {
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
        .loadingView(.constant(viewStore.state.loadingState == .loading), Texts.uploadingPhoto)
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

//extension View {
//	public func viewSnapshot() -> UIImage {
//		let controller = UIHostingController(rootView: self)
//		let view = controller.view
//
//		let targetSize = controller.view.intrinsicContentSize
//		view?.bounds = CGRect(origin: .zero, size: targetSize)
//		view?.backgroundColor = .clear
//
//		let renderer = UIGraphicsImageRenderer(size: targetSize)
//
//		return renderer.image { _ in
//			view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//		}
//	}
//}

