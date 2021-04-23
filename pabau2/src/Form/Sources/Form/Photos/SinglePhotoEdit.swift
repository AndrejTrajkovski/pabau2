import SwiftUI
import ComposableArchitecture
import PencilKit
import Combine
import Model

enum CanvasMode: Equatable {
	case drawing
	case injectables
}

func draw(injectionSize: CGSize,
		  widthToHeight: CGFloat,
			injection: Injection,
		  in ctxt: CGContext) {
	fatalError("TODO Cristan")
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
        case .saveDrawings:
            let size = state.photoSize
            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { (ctx) in
                if case .saved(let savedPhoto) = state.photo.basePhoto {
                    if let photoImageURLString = savedPhoto.normalSizePhoto, let url = URL(string: photoImageURLString) {
                        if let dataImage = try? Data(contentsOf: url) {
                            if let pImage = UIImage(data: dataImage) {
                                pImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                            }
                        }
					}
				}
				
				state.injectables.photoInjections.values.forEach { (injections: IdentifiedArrayOf<Injection>) in
					injections.forEach { injection in
						draw(injectionSize: InjectableMarker.MarkerSizes.markerSize,
							 widthToHeight: InjectableMarker.MarkerSizes.wToHRatio,
							 injection: injection,
							 in: ctx)
					}
				}
                state.photo.drawing.image(from: CGRect(x: 0, y: 0, width: size.width, height: size.height), scale: 1)
                    .draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                
            }
            state.imageInjectable = img
            
            return Just(SinglePhotoEditAction.uploadPhoto(img))
                .eraseToEffect()
        case .onChangePhotoSize(let size):
            state.photoSize = size
        case .uploadPhoto(let image):
            var params: [String: String] = [
                "booking_id": "0",
                "delete": "0",
                "contact_id": UserDefaults.standard.string(forKey: "selectedClientId") ?? "",
                "photo_id": state.editingPhotoId?.description ?? "",
            ]
            
            return env.formAPI
                .uploadClientEditedImage(image: image.pngData()!, params: params)
                .catchToEffect()
                .map { response in
                    switch response {
                    case .success(let voResponse):
                        print(voResponse)
                    case .failure(let error):
                        print(error)
                    }
                    return SinglePhotoEditAction.photoUploadResponse
                }
        case .photoUploadResponse:
            break
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
    var editingPhotoId: PhotoVariantId?

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
    case uploadPhoto(UIImage)
    case photoUploadResponse
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
