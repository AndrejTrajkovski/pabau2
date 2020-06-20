import SwiftUI
import AVFoundation
import Model
import PencilKit
import ComposableArchitecture
import Util

let editPhotosReducer = Reducer<EditPhotosState, EditPhotoAction, JourneyEnvironment>
	.combine(
		editPhotosListReducer.pullback(
			state: \.self,
			action: /EditPhotoAction.editPhotoList,
			environment: { $0 }),
		editSinglePhotoReducer.optional.pullback(
			state: \EditPhotosState.editSinglePhoto,
			action: /EditPhotoAction.editSinglePhoto,
			environment: { $0 }),
		.init { state, action, _ in
			switch action {
			case .openCamera:
				state.showingImagePicker = .camera
			case .closeCamera:
				state.showingImagePicker = nil
			case .didGetUIImage(let image):
				state.editingUIImage = image
			case .editSinglePhoto(_):
			break// inline
			case .editPhotoList(_):
				break
			}
			return .none
		}
)

public enum EditPhotoAction: Equatable {
	case openCamera
	case closeCamera
	case didGetUIImage(UIImage?)
	case editSinglePhoto(EditSinglePhotoAction)
	case editPhotoList(EditPhotosListAction)
}

public struct EditPhotosState: Equatable {
	var photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>
	var editingPhotoId: PhotoVariantId?

	init (_ photos: IdentifiedArray<PhotoVariantId, PhotoViewModel>) {
		self.photos = photos
		self.editingPhotoId = photos.last?.id
	}

	var showingImagePicker: UIImagePickerController.SourceType?
	var editingUIImage: UIImage?
	var isShowingCamera: Bool {
		get { self.showingImagePicker == .some(.camera) }
	}
}

struct EditPhotos: View {

	let store: Store<EditPhotosState, EditPhotoAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				EditPhotosList(store:
					self.store.scope(state: { $0 }, action: { .editPhotoList($0) })
				)
				VStack {
					IfLetStore(
						self.store.scope(
							state: { $0.editSinglePhoto },
							action: { .editSinglePhoto($0) }
						),
						then: EditSinglePhoto.init(store:),
						else: Spacer()
					)
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

	var editSinglePhoto: EditSinglePhotoState? {
		get {
			editingPhotoId.map {
				EditSinglePhotoState(photo: photos[id: $0]!)
			}
		}
		set {
			guard let newValue = newValue else { return }
			photos[id: newValue.photo.id] = newValue.photo
		}
	}
}
