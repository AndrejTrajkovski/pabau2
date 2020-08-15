import SwiftUI
import ComposableArchitecture
import Util

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
			state.newPhoto = image
			state.cameraType = nil
		case .onDismissImagePicker:
			state.cameraType = nil
		}
		return .none
}

public struct AddPhotoState: Equatable {
	var imageUrl: String?
	var newPhoto: UIImage?
	var selectCameraTypeActionSheet: ActionSheetState<AddPhotoAction>?
	var cameraType: UIImagePickerController.SourceType?

	public init(
		imageUrl: String?,
		newPhoto: UIImage?,
		selectCameraTypeActionSheet: ActionSheetState<AddPhotoAction>?,
		cameraType: UIImagePickerController.SourceType?
	) {
		self.imageUrl = imageUrl
		self.newPhoto = newPhoto
		self.selectCameraTypeActionSheet = selectCameraTypeActionSheet
		self.cameraType = cameraType
	}
}

public enum AddPhotoAction: Equatable {
	case onCameraType(UIImagePickerController.SourceType)
	case onTakePhoto(UIImage)
	case onTouchOnPhoto
	case actionSheetCancelled
	case onDismissImagePicker
}

//add uploading logic
struct AddPhotoParent: View {
	let store: Store<AddPhotoState, AddPhotoAction>
	var body: some View {
		WithViewStore(self.store) { viewStore in
			IfLetStore(self.store.scope(state: { $0.newPhoto }),
								 then: { thisStore in
									Image(uiImage: ViewStore(thisStore).state)
									.resizable()
									.aspectRatio(contentMode: .fit)
			}, else:
				ProfilePicWebImage(url: viewStore.imageUrl)
			)
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
