import SwiftUI
import AVFoundation
import Model
import PencilKit
import ComposableArchitecture
import Util

let editPhotosReducer = Reducer<EditPhotosState, EditPhotoAction, JourneyEnvironment>
	.combine(
		editPhotosRightSideReducer.pullback(
			state: \EditPhotosState.rightSide,
			action: /EditPhotoAction.rightSide,
			environment: { $0 }),
		editPhotosListReducer.pullback(
			state: \.self,
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
			case .closeCamera:
				state.isCameraActive = false
			case .editPhotoList, .rightSide, .cameraOverlay, .singlePhotoEdit:
				break
			}
			return .none
		}
)

public enum EditPhotoAction: Equatable {
	case openCamera
	case closeCamera
	case editPhotoList(EditPhotosListAction)
	case rightSide(EditPhotosRightSideAction)
	case cameraOverlay(CameraOverlayAction)
	case singlePhotoEdit(SinglePhotoEditAction)
}

public struct EditPhotosState: Equatable {
	var photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>
	var editingPhotoId: PhotoVariantId?
	var isTagsAlertActive: Bool = false
	var stencils = ["stencil1", "stencil2", "stencil3", "stencil4"]
	var isShowingPhotoLib: Bool = false
	var isShowingStencils: Bool = false
	var selectedStencilIdx: Int?
	var isFlashOn: Bool = false
	var frontOrRear: UIImagePickerController.CameraDevice = .rear
	var allInjectables: [Injectable] = JourneyMocks.injectables()
	var activeCanvas: ActiveCanvas = .drawing
	var chosenIncrement: Double = 0
	var chosenInjectable: Injectable?
	
	private var showingImagePicker: UIImagePickerController.SourceType?

	init (_ photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>) {
		self.photos = photos
		self.editingPhotoId = photos.last?.id
	}

	var isCameraActive: Bool {
		get { self.showingImagePicker == .some(.camera) }
		set { self.showingImagePicker = newValue ? .some(.camera) : nil}
	}
	var isPhotosAlbumActive: Bool {
		get { self.showingImagePicker == .some(.savedPhotosAlbum) }
		set { self.showingImagePicker = newValue ? .some(.savedPhotosAlbum) : nil}
	}
}

struct EditPhotos: View {

	let store: Store<EditPhotosState, EditPhotoAction>
	init (store: Store<EditPhotosState, EditPhotoAction>) {
		self.store = store
	}

	var body: some View {
		WithViewStore(store.scope(state: { $0.isCameraActive})) { viewStore in
			HStack {
				EditPhotosList(store:
					self.store.scope(state: { $0 }, action: { .editPhotoList($0) })
				)
					.frame(width: 92)
					.padding(8)
				IfLetStore(
					self.store.scope(
						state: { $0.singlePhotoEdit },
						action: { .singlePhotoEdit($0) }
					),
					then:
					SinglePhotoEdit.init(store:),
					else: Spacer()
				)
					.padding(.bottom, 128)
				EditPhotosRightSide(store:
					self.store.scope(
						state: { $0.rightSide },
						action: { .rightSide($0)}
					)
				)
					.padding(8)
					.padding(.bottom, 64)
			}
			.navigationBarItems(trailing:
				EmptyView()
			)
			.modalLink(isPresented: .constant(viewStore.state),
								 linkType: ModalTransition.fullScreenModal,
								 destination: {
									IfLetStore(self.store.scope(
										state: { $0.cameraOverlay },
										action: { .cameraOverlay($0) }),
														 then: ImagePicker.init(store:)
									).navigationBarHidden(true)
										.navigationBarTitle("")
			})
//			.sheet(isPresented: viewStore.binding(
//				get: { $0.isShowingCamera }, send: { _ in EditPhotoAction.closeCamera }),
//							content: {
//								ImagePicker(image:
//									viewStore.binding(
//										get: { $0.editingUIImage },
//										send: { .didGetUIImage($0) }
//									)
//								)
//			}
//			)
//			.onAppear(perform: { //show camera })
		}.debug("Edit Photos")
////		.popover(isPresented: Binding(
////			get: { self.showingImagePicker == .some(.photoLibrary) },
////			set: { self.showingImagePicker = $0 == true ? .some(.photoLibrary) : nil}
////			), content: {
////				ImagePicker(image: self.$inputImage)
////		})
	}
}

extension EditPhotos {

	func showImagePickerForCamera(_ sender: UIButton) {
		let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

		if authStatus == AVAuthorizationStatus.denied {
			let alert = UIAlertController(title: "Unable to access the Camera",
																		message: "To turn on camera access, choose Settings > Privacy > Camera and turn on Camera access for this app.",
																		preferredStyle: UIAlertController.Style.alert)

			let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
			alert.addAction(okAction)

			let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
				// Take the user to the Settings app to change permissions.
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { _ in
						// The resource finished opening.
					})
				}
			})
			alert.addAction(settingsAction)
//			present(alert, animated: true, completion: nil)
		} else if authStatus == AVAuthorizationStatus.notDetermined {
			AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
				if granted {
//					DispatchQueue.main.async {
//						self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
//					}
				}
			})
		} else {
//			showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
		}
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
															 isTagsAlertActive: self.isTagsAlertActive)
		}
		set {
			self.photos = newValue.photos
			self.editingPhotoId = newValue.editingPhotoId
			self.isCameraActive = newValue.isCameraActive
			self.isTagsAlertActive = newValue.isTagsAlertActive
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
				chosenIncrement: self.chosenIncrement,
				chosenInjectable: self.chosenInjectable)
		}
		set {
			self.editingPhoto = newValue?.photo
			guard let newValue = newValue else { return }
			self.activeCanvas = newValue.activeCanvas
			self.chosenIncrement = newValue.chosenIncrement
			self.chosenInjectable = newValue.chosenInjectable
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
