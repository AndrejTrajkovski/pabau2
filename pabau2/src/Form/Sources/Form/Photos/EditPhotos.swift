import SwiftUI
import AVFoundation
import Model
import PencilKit
import ComposableArchitecture
import Util

public let editPhotosReducer = Reducer<EditPhotosState, EditPhotoAction, FormEnvironment>
	.combine(
		editPhotosRightSideReducer.pullback(
			state: \EditPhotosState.rightSide,
			action: /EditPhotoAction.rightSide,
			environment: { $0 }),
		editPhotosListReducer.pullback(
			state: \EditPhotosState.editPhotoList,
			action: /EditPhotoAction.editPhotoList,
			environment: { $0 }),
		singlePhotoEditReducer.optional.pullback(
			state: \EditPhotosState.singlePhotoEdit,
			action: /EditPhotoAction.singlePhotoEdit,
			environment: { $0 }),
		cameraOverlayReducer.optional.pullback(
			state: \EditPhotosState.cameraOverlay,
			action: /EditPhotoAction.cameraOverlay,
			environment: { $0 }),
		.init { state, action, _ in
			switch action {
			case .openCamera:
				state.isCameraActive = true
			case .openPhotoAlbum:
				state.isPhotosAlbumActive = true
            case .editPhotoList, .rightSide, .cameraOverlay, .singlePhotoEdit, .chooseInjectables, .goBack:
				break
            case .save:
                break
			}
			return .none
		}
)

public enum EditPhotoAction: Equatable {
	case openCamera
	case openPhotoAlbum
	case editPhotoList(EditPhotosListAction)
	case rightSide(EditPhotosRightSideAction)
	case cameraOverlay(CameraOverlayAction)
	case singlePhotoEdit(SinglePhotoEditAction)
	case chooseInjectables(ChooseInjectableAction)
    case goBack
    case save
}

public struct EditPhotosState: Equatable {
	var photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>
	var editingPhotoId: PhotoVariantId?
	var isTagsAlertActive: Bool = false
	var stencils = ["stencil1", "stencil2", "stencil3", "stencil4"]
	var isShowingPhotoLib: Bool = false
	var isShowingStencils: Bool = true//false
	var selectedStencilIdx: Int?
	var isFlashOn: Bool = false
	var frontOrRear: UIImagePickerController.CameraDevice = .rear
	var activeCanvas: CanvasMode = .drawing
	var allInjectables: IdentifiedArrayOf<Injectable> = .init(Injectable.injectables())
	var isChooseInjectablesActive: Bool = false
	var chosenInjectableId: InjectableId?
	var deletePhotoAlert: AlertState<EditPhotosRightSideAction>?

	private var showingImagePicker: UIImagePickerController.SourceType?

	public init (_ photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>) {
		self.photos = photos
		self.editingPhotoId = photos.last?.id
		self.isCameraActive = self.photos.isEmpty
	}
    
    public init(_ photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>, currentPhoto: PhotoVariantId) {
        self.photos = photos
        self.editingPhotoId = currentPhoto
        self.isCameraActive = self.photos.isEmpty
    }

	var isCameraActive: Bool {
		get { self.showingImagePicker == .some(.camera) }
		set { self.showingImagePicker = newValue ? .some(.camera) : nil }
	}
	var isPhotosAlbumActive: Bool {
		get { self.showingImagePicker == .some(.photoLibrary) }
		set { self.showingImagePicker = newValue ? .some(.photoLibrary) : nil }
	}
}

public struct EditPhotos: View {

	let store: Store<EditPhotosState, EditPhotoAction>
	public init (store: Store<EditPhotosState, EditPhotoAction>) {
		self.store = store
	}

	struct State: Equatable {
		let isPhotosAlbumActive: Bool
		let isCameraActive: Bool
		let isChooseInjectablesActive: Bool
		let editingPhotoId: PhotoVariantId?
		let isDrawingDisabled: Bool
		init (state: EditPhotosState) {
			self.isCameraActive = state.isCameraActive
			self.isChooseInjectablesActive = state.isChooseInjectablesActive
			self.editingPhotoId = state.editingPhotoId
			self.isDrawingDisabled = state.activeCanvas != .drawing
			self.isPhotosAlbumActive = state.isPhotosAlbumActive
		}
	}

	public var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			VStack {
				HStack {
					EditPhotosList(store:
						self.store.scope(state: { $0.editPhotoList }, action: { .editPhotoList($0) })
					)
						.frame(width: 92)
					IfLetStore(
						self.store.scope(
							state: { $0.singlePhotoEdit },
							action: { .singlePhotoEdit($0) }
						),
						then:
						SinglePhotoEdit.init(store:),
						else: Text("No photos selected. Select or take a new photo.")
					)
					.frame(minWidth: 0, maxWidth: .infinity)
					EditPhotosRightSide(store:
						self.store.scope(
							state: { $0.rightSide },
							action: { .rightSide($0)}
						)
					)
						.frame(width: 92)
				}
				Group {
					if viewStore.state.isDrawingDisabled {
						IfLetStore(self.store.scope(
							state: { $0.singlePhotoEdit?.injectables.injectablesTool },
							action: { .singlePhotoEdit(SinglePhotoEditAction.injectables(InjectablesAction.injectablesTool($0)))}), then: {
								InjectablesTool(store: $0)
							}, else: Color.clear
						)
					} else {
						Color.clear
					}
				}
				.frame(height: 128)
//				.padding()
			}
                .navigationBarItems(leading:
                                        MyBackButton(text: Texts.back, action: { viewStore.send(.goBack)}
                                        ), trailing:
                                            Button(action: { viewStore.send(.save) }, //viewStore.send(.saveEdited) },
                                                   label: { Text(Texts.save) })
                )
                .navigationBarBackButtonHidden(true)

				.modalLink(isPresented: .constant(viewStore.state.isPhotosAlbumActive),
									 linkType: ModalTransition.fullScreenModal,
									 destination: {
										IfLetStore(self.store.scope(
											state: { $0.cameraOverlay },
											action: { .cameraOverlay($0) }),
															 then: PhotoLibraryPicker.init(store:)
										)
											.navigationBarHidden(true)
											.navigationBarTitle("")
				})
				.modalLink(isPresented: .constant(viewStore.state.isCameraActive),
								 linkType: ModalTransition.fullScreenModal,
								 destination: {
									IfLetStore(self.store.scope(
										state: { $0.cameraOverlay },
										action: { .cameraOverlay($0) }),
														 then: ImagePicker.init(store:)
									).navigationBarHidden(true)
										.navigationBarTitle("")
			})
		}.debug("Edit Photos")
	}
}

extension EditPhotosState {

	var cameraOverlay: CameraOverlayState? {
		get {
			CameraOverlayState(
				photos: self.photos,
				editingPhotoId: self.editingPhotoId,
				isCameraActive: self.isCameraActive,
				stencils: self.stencils,
				selectedStencilIdx: self.selectedStencilIdx,
				isShowingStencils: self.isShowingStencils,
				isShowingPhotoLib: self.isShowingPhotoLib,
				isFlashOn: self.isFlashOn,
				frontOrRear: self.frontOrRear,
				allInjectables: self.allInjectables
			)
		}
		set {
			guard let newValue = newValue else { return }
			self.photos = newValue.photos
			self.editingPhotoId = newValue.editingPhotoId
			self.isCameraActive = newValue.isCameraActive
			self.stencils = newValue.stencils
			self.selectedStencilIdx = newValue.selectedStencilIdx
			self.isShowingStencils = newValue.isShowingStencils
			self.isShowingPhotoLib = newValue.isShowingPhotoLib
			self.isFlashOn = newValue.isFlashOn
			self.frontOrRear = newValue.frontOrRear
			self.allInjectables = newValue.allInjectables
		}
	}

	var rightSide: EditPhotosRightSideState {
		get {
			EditPhotosRightSideState(photos: self.photos,
															 editingPhotoId: self.editingPhotoId,
															 isCameraActive: self.isCameraActive,
															 isTagsAlertActive: self.isTagsAlertActive,
															 activeCanvas: self.activeCanvas,
															 isChooseInjectablesActive: self.isChooseInjectablesActive,
															 chosenInjectableId: self.chosenInjectableId,
															 isPhotosAlbumActive: self.isPhotosAlbumActive,
															 deletePhotoAlert: self.deletePhotoAlert
			)
		}
		set {
			self.photos = newValue.photos
			self.editingPhotoId = newValue.editingPhotoId
			self.isCameraActive = newValue.isCameraActive
			self.isTagsAlertActive = newValue.isTagsAlertActive
			self.activeCanvas = newValue.activeCanvas
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.chosenInjectableId = newValue.chosenInjectableId
			self.isPhotosAlbumActive = newValue.isPhotosAlbumActive
			self.deletePhotoAlert = newValue.deletePhotoAlert
		}
	}

	var singlePhotoEdit: SinglePhotoEditState? {
		get {
			guard let editingPhoto = editingPhoto else {
				return nil
			}
			return SinglePhotoEditState(
				activeCanvas: self.activeCanvas,
				photo: editingPhoto,
				allInjectables: self.allInjectables,
				isChooseInjectablesActive: self.isChooseInjectablesActive,
				chosenInjectatbleId: self.chosenInjectableId
			)
		}
		set {
			self.editingPhoto = newValue?.photo
			guard let newValue = newValue else { return }
			self.activeCanvas = newValue.activeCanvas
			self.allInjectables = newValue.allInjectables
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.chosenInjectableId = newValue.chosenInjectatbleId
		}
	}

	var editingPhoto: PhotoViewModel? {
		get {
			getPhoto(photos, editingPhotoId)
		}
		set {
			set(newValue, onto: &photos)
		}
	}

	var editPhotoList: EditPhotosListState {
		get {
			EditPhotosListState(
				photos: self.photos,
				editingPhotoId: self.editingPhotoId)
		}
		set {
			self.photos = newValue.photos
			self.editingPhotoId = newValue.editingPhotoId
		}
	}
}

func set(_ photo: PhotoViewModel?,
				 onto photos:inout IdentifiedArrayOf<PhotoViewModel>) {
	guard let photo = photo else { return }
	photos[id: photo.id] = photo
}

func getPhoto(_ photos: IdentifiedArrayOf<PhotoViewModel>,
							_ id: PhotoVariantId?) -> PhotoViewModel? {
	return id.map {
		photos[id: $0]!
	}
}


extension View {
    public func snapshot() -> UIImage {
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
