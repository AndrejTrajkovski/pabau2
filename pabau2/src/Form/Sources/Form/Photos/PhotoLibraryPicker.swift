import SwiftUI
import BSImagePicker
import Photos
import ComposableArchitecture

struct PhotoLibraryPicker: UIViewControllerRepresentable {

	let store: Store<CameraOverlayState, CameraOverlayAction>
	let viewStore: ViewStore<CameraOverlayState, CameraOverlayAction>

	init(store: Store<CameraOverlayState, CameraOverlayAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	typealias UIViewControllerType = BSImagePicker.ImagePickerController

	func makeUIViewController(context: Context) -> ImagePickerController {
		let imagePicker = ImagePickerController()
		imagePicker.settings.theme.selectionStyle = .checked
		imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
		imagePicker.imagePickerDelegate = context.coordinator
		return imagePicker
	}

	func updateUIViewController(_ uiViewController: ImagePickerController, context: Context) {

	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject {
		var parent: PhotoLibraryPicker
		init(_ parent: PhotoLibraryPicker) {
			self.parent = parent
		}
	}
}

extension PhotoLibraryPicker.Coordinator: ImagePickerControllerDelegate, UINavigationControllerDelegate {

	func getAssetImage(asset: PHAsset) -> UIImage {
		let manager = PHImageManager.default()
		let option = PHImageRequestOptions()
		var thumbnail = UIImage()
		option.isSynchronous = true
		manager.requestImage(for: asset,
												 targetSize: PHImageManagerMaximumSize,
												 contentMode: .aspectFit,
												 options: option,
												 resultHandler: {(result, _) -> Void in
													thumbnail = result!
		})
		return thumbnail
	}

	func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset]) {
		parent.viewStore.send(.didTakePhotos(assets.map(getAssetImage(asset:))))
	}

	func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset) {
		//do nothing
	}

	func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset) {
		//do nothing
	}

	func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
		//do nothing
	}

	func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
		//do nothing
		parent.viewStore.send(.onClosePhotosLibrary)
	}
}
