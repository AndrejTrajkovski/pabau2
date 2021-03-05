import SwiftUI
import ComposableArchitecture
import Util
import UIKit
import Model
import Avatar

struct UploadPhotoId: Hashable {}

public let addPhotoReducer: Reducer<AddPhotoState, AddPhotoAction, ClientsEnvironment> =
	.init { state, action, env in
		
		switch action {
		case .onTouchOnPhoto:
			state.selectCameraTypeActionSheet = ActionSheetState(
				title: "Choose Photo Source",
				buttons: [
					.default("Camera", send: .onCameraType(.camera)),
					.default("Library", send: .onCameraType(.photoLibrary)),
					.destructive("Cancel", send: .actionSheetCancelled)
				]
			)
		case .actionSheetCancelled:
			state.selectCameraTypeActionSheet = nil
		case .onCameraType(let sourceType):
			state.selectCameraTypeActionSheet = nil
			state.cameraType = sourceType
		case .onTakePhoto(let image):
			let scaledImage = image.scalePreservingAspectRatio(targetSize: CGSize.init(width: 1024, height: 1024))
			state.photoUploading = .loading
			state.newPhoto = scaledImage
			state.cameraType = nil
			let imageData = scaledImage.jpegData(compressionQuality: 0.5)!
			return env.formAPI.updateProfilePic(image: imageData, clientId: state.patDetails.id)
				.receive(on: DispatchQueue.main)
				.catchToEffect()
				.map(AddPhotoAction.photoUploadResponse)
				.cancellable(id: UploadPhotoId())
		case .onDismissImagePicker:
			state.cameraType = nil
		case .photoUploadResponse(let result):
			switch result {
			case .success:
				state.photoUploading = .gotSuccess
			case .failure(let error):
				state.photoUploading = .gotError(error)
			}
		}
		return .none
}

public struct AddPhotoState: Equatable {
	var patDetails: PatientDetails
	var newPhoto: UIImage?
	var selectCameraTypeActionSheet: ActionSheetState<AddPhotoAction>?
	var cameraType: UIImagePickerController.SourceType?
	var photoUploading: LoadingState
	
	public init(
		patDetails: PatientDetails,
		newPhoto: UIImage?,
		selectCameraTypeActionSheet: ActionSheetState<AddPhotoAction>?,
		cameraType: UIImagePickerController.SourceType?,
		photoUploading: LoadingState
	) {
		self.patDetails = patDetails
		self.newPhoto = newPhoto
		self.selectCameraTypeActionSheet = selectCameraTypeActionSheet
		self.cameraType = cameraType
		self.photoUploading = photoUploading
	}
}

public enum AddPhotoAction: Equatable {
	case onCameraType(UIImagePickerController.SourceType)
	case onTakePhoto(UIImage)
	case onTouchOnPhoto
	case actionSheetCancelled
	case onDismissImagePicker
	case photoUploadResponse(Result<VoidAPIResponse, RequestError>)
}

//add uploading logic
struct AddPhotoParent: View {
	let store: Store<AddPhotoState, AddPhotoAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			ClientAvatarUpload(store: store.scope(state: { $0.clientAvatar }).actionless)
				.frame(width: 123, height: 100)
				.onTapGesture {
					viewStore.send(.onTouchOnPhoto)
			}
			.actionSheet(self.store.scope(state: \.selectCameraTypeActionSheet),
									 dismiss: .actionSheetCancelled)
				.sheet(isPresented: viewStore.binding(
					get: { $0.cameraType != nil },
					send: { _ in .onDismissImagePicker }
				)) {
//						IfLetStore(self.store.scope(
//											state: { $0 },
//											action: { $0 }),
//															 then: { imagePickerStore in
																ImagePickerView.init(sourceType: viewStore.state.cameraType!, onImagePicked: {
																	viewStore.send(.onTakePhoto($0))
																})
//										}
//				)
			}
		}
	}
}

extension AddPhotoState {
	var clientAvatar: ClientAvatarUploadState {
		get {
			ClientAvatarUploadState(
				newPhoto: self.newPhoto,
				photoUploading: self.photoUploading,
				patDetails: self.patDetails
			)
		}
		set {
			self.newPhoto = newValue.newPhoto
			self.photoUploading = newValue.photoUploading
			self.patDetails = newValue.patDetails
		}
	}
}

struct ClientAvatarUploadState: Equatable {
	var newPhoto: UIImage?
	var photoUploading: LoadingState
	var patDetails: PatientDetails
}

struct ClientAvatarUpload: View {
	let store: Store<ClientAvatarUploadState, Never>
	var body: some View {
		WithViewStore(store) { viewStore in
			switch viewStore.photoUploading {
			case .initial:
				ClientAvatar(store: store.scope(state: { Client(patDetails: $0.patDetails) }))
			case .loading:
				VStack {
					ActivityIndicator(isAnimating: .constant(true), style: .large)
					Text("Uploading...").foregroundColor(.accentColor)
				}
			case .gotSuccess:
					Image(uiImage: viewStore.newPhoto!)
						.resizable()
						.clipShape(Circle())
			case .gotError:
				ZStack {
					ClientAvatar(store: store.scope(state: { Client(patDetails: $0.patDetails) }))
					Text("Update Failed.").foregroundColor(.red)
				}
			}
		}
	}
}

extension UIImage {
	func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
		// Determine the scale factor that preserves aspect ratio
		let widthRatio = targetSize.width / size.width
		let heightRatio = targetSize.height / size.height
		let scaleFactor = min(widthRatio, heightRatio)
		// Compute the new image size that preserves aspect ratio
		let scaledImageSize = CGSize(
			width: size.width * scaleFactor,
			height: size.height * scaleFactor
		)

		// Draw and return the resized UIImage
		let renderer = UIGraphicsImageRenderer(
			size: scaledImageSize
		)

		let scaledImage = renderer.image { _ in
			self.draw(in: CGRect(
				origin: .zero,
				size: scaledImageSize
			))
		}
		
		return scaledImage
	}
}
