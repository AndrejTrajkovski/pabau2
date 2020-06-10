import SwiftUI
import AVFoundation
import Model
import PencilKit
import ComposableArchitecture
import Util

let editPhotoReducer = Reducer<EditPhotoState, EditPhotoAction, JourneyEnvironment>.init { state, action, _ in
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

struct EditPhotoState: Equatable {
	var showingImagePicker: UIImagePickerController.SourceType?
	var editingPhotoId: Int
	var photosOrderedIds: [Int]
	var photos: [Int: JourneyPhotos]
	var drawings: [Int: [PKDrawing]]
	var editingUIImage: UIImage?
	var sortedPhotos: [JourneyPhotos] {
		photosOrderedIds.map { photos[$0]! }
	}
	var editingPhoto: JourneyPhotos {
		get { photos[editingPhotoId]! } set { photos[editingPhotoId] = newValue }
	}
	var editingDrawings: [PKDrawing] {
		drawings[editingPhotoId]!
	}
	var isShowingCamera: Bool {
		get { self.showingImagePicker == .some(.camera) }
//		set { self.showingImagePicker = newValue == true ? .some(.camera) : nil }
	}
}

struct EditPhoto: View {

	let store: Store<EditPhotoState, EditPhotoAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				Image(viewStore.state.editingPhoto.url)
					.resizable()
					.scaledToFit()
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

extension EditPhoto {

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
