import SwiftUI
import AVFoundation
import Model
import PencilKit
import ComposableArchitecture

let editPhotoReducer = Reducer<EditPhotoState, EditPhotoAction, JourneyEnvironment>.init { state, action, env in
	switch action {
	case .openCamera:
		state.showingImagePicker = .camera
	}
	return .none
}

public enum EditPhotoAction {
	case openCamera
}

struct EditPhotoState: Equatable {
	var showingImagePicker: UIImagePickerController.SourceType?
	var editingPhotoId: Int
	var photosOrderedIds: [Int]
	var photos: [Int: JourneyPhotos]
	var drawings: [Int: [PKDrawing]]
	var sortedPhotos: [JourneyPhotos] {
		photosOrderedIds.map { photos[$0]! }
	}
	var editingPhoto: JourneyPhotos {
		photos[editingPhotoId]!
	}
	var editingDrawings: [PKDrawing] {
		drawings[editingPhotoId]!
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
		}
////		.popover(isPresented: Binding(
////			get: { self.showingImagePicker == .some(.photoLibrary) },
////			set: { self.showingImagePicker = $0 == true ? .some(.photoLibrary) : nil}
////			), content: {
////				ImagePicker(image: self.$inputImage)
////		})
//			.sheet(isPresented: Binding(
//				get: { self.showingImagePicker == .some(.camera) },
//				set: { self.showingImagePicker = $0 == true ? .some(.camera) : nil}
//				),
//						 onDismiss: loadImage) {
//				ImagePicker(image: self.$inputImage)
//		}.onAppear(perform: { self.showingImagePicker = .camera })
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
