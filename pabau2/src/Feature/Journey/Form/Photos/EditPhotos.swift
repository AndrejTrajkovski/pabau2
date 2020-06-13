import SwiftUI
import AVFoundation
import Model
import PencilKit
import ComposableArchitecture
import Util

let editPhotosReducer = Reducer<EditPhotosState, EditPhotoAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .openCamera:
		state.showingImagePicker = .camera
	case .closeCamera:
		state.showingImagePicker = nil
	case .didGetUIImage(let image):
		state.editingUIImage = image
	}
	return .none
}

public enum EditPhotoAction: Equatable {
	case openCamera
	case closeCamera
	case didGetUIImage(UIImage?)
}

public enum PhotoVariantId: Equatable, Hashable {
	case saved(Int)
	case new(UUID)
}

struct PhotosCollection: Equatable {
	
}

struct EditPhotosState: Equatable {
	var currentDrawing: PKDrawing = PKDrawing()
	var editingPhotoId: PhotoVariantId
	
	var newPhotosOrder: [UUID]
	var newPhotos: [UUID: NewPhoto]
	var drawings: [UUID: PKDrawing]
	
	var savedPhotosOrder: [Int]
	var savedPhotos: [Int: SavedPhoto]
	
	var showingImagePicker: UIImagePickerController.SourceType?
	var editingUIImage: UIImage?
	var isShowingCamera: Bool {
		get { self.showingImagePicker == .some(.camera) }
	}
//	var editSinglePhoto: EditSinglePhotoState {
//		get {
//			EditSinglePhotoState(photo: <#T##Photo#>, drawing: <#T##PKDrawing#>)
//		}
//	}
}

struct EditPhotos: View {

	let store: Store<EditPhotosState, EditPhotoAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				//EditSinglePhoto
				Button("Select Image") {
					viewStore.send(.openCamera)
				}
			}
			.modalLink(isPresented: .constant(viewStore.state.isShowingCamera),
									 linkType: ModalTransition.fullScreenModal,
									 destination: {
										ImagePicker(image:
											viewStore.binding(
												get: { $0.editingUIImage },
												send: { .didGetUIImage($0) }
											)
										)
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
		}
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
	
	func selectedPhoto() -> Photo {
		switch editingPhotoId {
		case .new(let uuid):
			return Photo.new(newPhotos[uuid]!)
		case .saved(let id):
			return Photo.saved(savedPhotos[id]!)
		}
	}
	
	var editSinglePhoto: EditSinglePhotoState {
		get { EditSinglePhotoState(photo: self.selectedPhoto(),
															 drawing: currentDrawing)}
		set { self.currentDrawing = newValue.drawing }
	}
	
}
