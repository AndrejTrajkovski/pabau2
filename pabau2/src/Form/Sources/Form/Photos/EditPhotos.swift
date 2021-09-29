import SwiftUI
import AVFoundation
import Model
import PencilKit
import ComposableArchitecture
import Util
import AlertToast
import Combine

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
		singlePhotoEditReducer.optional().pullback(
			state: \EditPhotosState.singlePhotoEdit,
			action: /EditPhotoAction.singlePhotoEdit,
			environment: { $0 }),
		cameraOverlayReducer.optional().pullback(
			state: \EditPhotosState.cameraOverlay,
			action: /EditPhotoAction.cameraOverlay,
			environment: { $0 }),
		.init { state, action, env in
			switch action {
			case .openPhotoAlbum:
				state.isPhotosAlbumActive = true
            case .editPhotoList, .cameraOverlay, .chooseInjectables:
                break
            case .save:
                var uploadsActions: [Effect<EditPhotoAction, Never>] = []
                for idx in state.photos.indices {
                    let photo = state.photos[idx]
                    let id = photo.id
                    state.photos[id: id]?.savePhotoState = .loading
                    let renderAndUploadEffect = renderAndUpload(photo,
                                                                idx,
                                                                state.pathwayIdStepId,
                                                                state.clientId,
                                                                nil,
                                                                env.formAPI)
                    let action = renderAndUploadEffect
                        .catchToEffect()
                        .receive(on: DispatchQueue.main)
                        .eraseToEffect()
                        .map {
                            EditPhotoAction.saveResponse(id: id, result: $0)
                        }
                    uploadsActions.append(action)
                }
                return Effect.concatenate(uploadsActions)
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .cancellable(id: UploadPhotoId())
            case .goBack:
                if state.isSavingPhotos {
                    state.uploadAlert = AlertState(title: TextState(Texts.uploadAlertTitle),
                                                   message: TextState(Texts.uploadAlertMessage),
                                                   primaryButton: .destructive(TextState("Yes"), send: .abortUpload),
                                                   secondaryButton: .default(TextState("No"), send: .continueUpload))
                } else {
                    break//parent reducer
                }
            case .abortUpload:
                break//parent reducer
            case .continueUpload:
                state.uploadAlert = nil
            case .rightSide(.didTouchTrash):
                state.deletePhotoAlert = AlertState(
                    title: TextState("Delete Photo"),
                    message: TextState("Are you sure you want to delete this photo?"),
                    primaryButton: .default(TextState("Yes"),
                                            send: EditPhotoAction.rightSide(.deleteAlertConfirmed)),
                    secondaryButton: .cancel()
                )
            case .rightSide(.deleteAlertConfirmed):
                state.deletePhotoAlert = nil
                guard let editingPhotoId = state.editingPhotoId else { break }
                let toBeSelected: PhotoViewModel?
                if state.photos.count > 1,
                   let idx = state.photos.index(id: editingPhotoId) {
                    if let elementAfter = state.photos[safe: state.photos.index(after: idx)] {
                        toBeSelected = elementAfter
                    } else if let elementBefore = state.photos[safe: state.photos.index(before: idx)] {
                        toBeSelected = elementBefore
                    } else {
                        toBeSelected = nil
                    }
                } else {
                    toBeSelected = nil
                }
                state.editingPhotoId = toBeSelected.map(\.id)
                state.photos.remove(id: editingPhotoId)
            case .saveResponse(let id, let result):
                print("here result")
                switch result {
                case .success(let voidApiResponse):
                    print(voidApiResponse)
                    state.photos[id: id]?.savePhotoState = .gotSuccess
                case .failure(let error):
                    print(error)
                    state.photos[id: id]?.savePhotoState = .gotError(error)
                }
                let allUploadsAreFinished = !state.isSavingPhotos
                if allUploadsAreFinished {
                    let savingStates = state.photos.map(\.savePhotoState)
                    let numberOfErrors = savingStates.filter { $0.isError }.count
                    if numberOfErrors > 0 {
                        state.uploadAlert = AlertState(title: TextState(Texts.errorUploadingPhotos),
                                                       message: TextState("\(numberOfErrors) photos failed to upload."),
                        dismissButton: .destructive(TextState("Ok"), send: .dismissUploadErrorAlert))
                    }
                }
            case .dismissUploadErrorAlert:
                state.uploadAlert = nil
            default:
                break
			}
			return .none
        }
    )

public enum EditPhotoAction: Equatable {
	case openPhotoAlbum
	case editPhotoList(EditPhotosListAction)
	case rightSide(EditPhotosRightSideAction)
	case cameraOverlay(CameraOverlayAction)
	case singlePhotoEdit(SinglePhotoEditAction)
	case chooseInjectables(ChooseInjectableAction)
    case goBack
    case save
    case showAlert
    case abortUpload
    case continueUpload
    case saveResponse(id: PhotoVariantId, result:(Result<SavedPhoto, RequestError>))
    case dismissUploadErrorAlert
}

public struct EditPhotosState: Equatable {

    var isSavingPhotos: Bool {
        return photos.map(\.savePhotoState).contains(where: { $0.isLoading })
    }

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
    var allInjectables: IdentifiedArrayOf<Injectable> = .init(uniqueElements: Injectable.injectables())
	var isChooseInjectablesActive: Bool = false
	var chosenInjectableId: InjectableId?
	var deletePhotoAlert: AlertState<EditPhotoAction>?
    var uploadAlert: AlertState<EditPhotoAction>?
    var isCameraActive: Bool
    var isPhotosAlbumActive: Bool
    let pathwayIdStepId: PathwayIdStepId
    let clientId: Client.ID
    
    public init (_ photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>, pathwayIdStepId: PathwayIdStepId, clientId: Client.ID) {
		self.photos = photos
		self.editingPhotoId = photos.last?.id
		self.isCameraActive = self.photos.isEmpty
        self.isPhotosAlbumActive = false
        self.pathwayIdStepId = pathwayIdStepId
        self.clientId = clientId
	}
    
//    public init(_ photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>, currentPhoto: PhotoVariantId, pathwayIdStepId: PathwayIdStepId) {
//        self.photos = photos
//        self.editingPhotoId = currentPhoto
//        self.isCameraActive = self.photos.isEmpty
//        self.isPhotosAlbumActive = false
//        self.pathwayIdStepId = pathwayIdStepId
//    }

    mutating func updateWith(editingPhoto: PhotoViewModel?) {
        if let editingPhoto = editingPhoto {
            photos[id: editingPhoto.id] = editingPhoto
        } else if let editingPhotoId = editingPhotoId {
            photos.remove(id: editingPhotoId)
            self.editingPhotoId = nil
        }
    }
    
    func getEditingPhoto() -> PhotoViewModel? {
        return editingPhotoId.map {
            photos[id: $0]!
        }
    }
}

public struct EditPhotos: View {

	let store: Store<EditPhotosState, EditPhotoAction>
    @ObservedObject var viewStore: ViewStore<State, EditPhotoAction>
    
	public init (store: Store<EditPhotosState, EditPhotoAction>) {
		self.store = store
        self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}

	struct State: Equatable {
		let isPhotosAlbumActive: Bool
		let isCameraActive: Bool
		let isChooseInjectablesActive: Bool
		let editingPhotoId: PhotoVariantId?
		let isDrawingDisabled: Bool
        let uploadingImagesMessage: String?
        let isSaveEnabled: Bool
		init (state: EditPhotosState) {
			self.isCameraActive = state.isCameraActive
			self.isChooseInjectablesActive = state.isChooseInjectablesActive
			self.editingPhotoId = state.editingPhotoId
			self.isDrawingDisabled = state.activeCanvas != .drawing
			self.isPhotosAlbumActive = state.isPhotosAlbumActive
            if state.isSavingPhotos {
                let savingStates = state.photos.map(\.savePhotoState)
                let numberOfPhotosSaving = savingStates.filter { $0 == .loading }.count
                uploadingImagesMessage = "Uploading photos \(savingStates.count - numberOfPhotosSaving + 1) / \(savingStates.count)"
            } else {
                uploadingImagesMessage = nil
            }
            self.isSaveEnabled = state.photos.allSatisfy { $0.basePhoto.imageData() != nil }
		}
	}
    
    public var body: some View {
        Group {
            if let uploadMessage = viewStore.uploadingImagesMessage {
                LoadingView.init(title:
                                    uploadMessage,
                                 bindingIsShowing: .constant(true),
                                 content: { EmptyView() }
                )
            } else {
                editPhotosMain
            }
        }
        .navigationBarItems(
            leading: backButton,
            trailing: saveButton
        )
        .navigationBarBackButtonHidden(true)
        .alert(
            store.scope(state: { $0.uploadAlert }),
            dismiss: EditPhotoAction.dismissUploadErrorAlert)
        .alert(
            store.scope(state: { $0.deletePhotoAlert }),
            dismiss: EditPhotoAction.rightSide(EditPhotosRightSideAction.deleteAlertCanceled))
	}

    var editPhotosMain: some View {
        VStack {
            HStack {
                EditPhotosList(store:
                                store.scope(state: { $0.editPhotoList },
                                            action: { .editPhotoList($0) })
                )
                .frame(width: 92)
                IfLetStore(
                    store.scope(
                        state: { $0.singlePhotoEdit },
                        action: { .singlePhotoEdit($0) }
                    ),
                    then: SinglePhotoEdit.init(store:),
                    else: { Text("No photos selected. Select or take a new photo.") }
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
                    injectablesPicker
                } else {
                    Color.clear
                }
            }
            .frame(height: 128)
        }
        .modalLink(isPresented: .constant(viewStore.state.isPhotosAlbumActive),
                   linkType: ModalTransition.fullScreenModal,
                   destination: { photosAlbum })
        .modalLink(isPresented: .constant(viewStore.state.isCameraActive),
                   linkType: ModalTransition.fullScreenModal,
                   destination: { camera })
    }

    var injectablesPicker: some View {
        IfLetStore(self.store.scope(
                    state: { $0.singlePhotoEdit?.injectables.injectablesTool },
                    action: { .singlePhotoEdit(SinglePhotoEditAction.injectables(InjectablesAction.injectablesTool($0)))}), then: {
                        InjectablesTool(store: $0)
                    }, else: { Color.clear }
        )
    }

    var backButton: some View {
        MyBackButton(text: Texts.back,
                              action: { viewStore.send(.goBack) })
    }

    var saveButton: some View {
        Button( action: { viewStore.send(.save) },
                          label: { Text(Texts.save) })
            .disabled(!viewStore.isSaveEnabled)
    }

    var photosAlbum: some View {
        IfLetStore(self.store.scope(
                    state: { $0.cameraOverlay },
                    action: { .cameraOverlay($0) }),
                   then: PhotoLibraryPicker.init(store:)
        )
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }

    var camera: some View {
        IfLetStore(self.store.scope(
                    state: { $0.cameraOverlay },
                    action: { .cameraOverlay($0) }),
                   then: ImagePicker.init(store:)
        ).navigationBarHidden(true)
        .navigationBarTitle("")
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
            EditPhotosRightSideState(photo: getEditingPhoto(),
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
            self.updateWith(editingPhoto: newValue.photo)
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
			guard let editingPhoto = getEditingPhoto() else {
				return nil
			}
			return SinglePhotoEditState(
				activeCanvas: self.activeCanvas,
				photo: editingPhoto,
				allInjectables: self.allInjectables,
				isChooseInjectablesActive: self.isChooseInjectablesActive,
				chosenInjectatbleId: self.chosenInjectableId,
                editingPhotoId: self.editingPhotoId,
                isAlertActive: (self.uploadAlert != nil) || (self.deletePhotoAlert != nil)
			)
		}
		set {
            updateWith(editingPhoto: newValue?.photo)
			guard let newValue = newValue else { return }
			self.activeCanvas = newValue.activeCanvas
			self.allInjectables = newValue.allInjectables
			self.isChooseInjectablesActive = newValue.isChooseInjectablesActive
			self.chosenInjectableId = newValue.chosenInjectatbleId
            self.editingPhotoId = newValue.editingPhotoId
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

func render(photoViewModel: PhotoViewModel) -> UIImage {
    render(injections: photoViewModel.injections,
           drawing: photoViewModel.drawing,
           image: photoViewModel.basePhoto.imageData()!)
}

func render(injections: [InjectableId : IdentifiedArrayOf<Injection>],
            drawing: Data,
            image: UIImage) -> UIImage {
    let size = image.size
    let renderer = UIGraphicsImageRenderer(size: size)
    let img = renderer.image { (ctx) in
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        injections.values.forEach { (injections: IdentifiedArrayOf<Injection>) in
            injections.forEach { injection in
                draw(injectionSize: InjectableMarker.MarkerSizes.markerSize,
                     widthToHeight: InjectableMarker.MarkerSizes.wToHRatio,
                     injection: injection)
            }
        }

        if let pencilImage = UIImage(data: drawing) {
            pencilImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
    }

    return img
}

func makeUploadData(photoViewModel: PhotoViewModel,
                    clientId: Client.ID,
                    employeeId: Employee.ID?) -> PhotoUpload {
    //TODO employee id from passcode when starting pathway, make employeeId non optional and follow compiler
    var params: [String: String] = ["contact_id": clientId.description,
                                    "counter": "1",
                                    "mode": "upload_photo",
                                    "photo_type": "contact"]
    if case .saved(let savedPhoto) = photoViewModel.basePhoto {
        params["photo_id"] = savedPhoto.id.description
    }
    if let employeeId = employeeId {
        params["uid"] = employeeId.description
    }
    let rendered = render(photoViewModel: photoViewModel).jpegData(compressionQuality: 0.5)!
    return PhotoUpload(fileData: rendered, params: params)
}


//background thread async
func renderAndUpload(_ photoViewModel: PhotoViewModel,
                     _ index: Int,
                     _ pathwayIdStepId: PathwayIdStepId,
                     _ clientId: Client.ID,
                     _ employeeId: Employee.ID?,
                     _ api: FormAPI) -> Effect<SavedPhoto, RequestError> {
    let renderedUploadData = render(photoViewModel, clientId, employeeId)
    let upload = renderedUploadData.flatMap {
        api.uploadImage(upload: $0, pathwayIdStepId: pathwayIdStepId)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
    }
    return upload.eraseToEffect()
}

func render(
    _ photoViewModel: PhotoViewModel,
    _ clientId: Client.ID,
    _ employeeId: Employee.ID?
) -> Effect<PhotoUpload, Never> {
    let uploadData = makeUploadData(photoViewModel: photoViewModel,
                                    clientId: clientId,
                                    employeeId: employeeId)
    return Just(uploadData).eraseToEffect()
}

func renderOnBgThread(
    _ photoViewModel: PhotoViewModel,
    _ clientId: Client.ID,
    _ employeeId: Employee.ID?
) -> Effect<PhotoUpload, Never> {
    return Effect.future { completion in
        DispatchQueue.global(qos: .userInitiated).async {
            let uploadData = makeUploadData(photoViewModel: photoViewModel,
                                            clientId: clientId,
                                            employeeId: employeeId)
            completion(.success(uploadData))
        }
    }
}
