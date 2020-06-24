import SwiftUI
import ComposableArchitecture

public let editPhotosRightSideReducer = Reducer<EditPhotosRightSideState, EditPhotosRightSideAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .didTouchTag:
		state.isTagsAlertActive = true
	case .didTouchPrivacy:
		state.editingPhoto?.isPrivate.toggle()
	case .didTouchTrash:
		guard let editingPhotoId = state.editingPhotoId else { break }
		state.photos.remove(id: editingPhotoId)
	case .didTouchCamera:
		state.isCameraActive = true
	}
	return .none
}

public struct EditPhotosRightSideState {
	var photos: IdentifiedArrayOf<PhotoViewModel>
	var editingPhotoId: PhotoVariantId?
	var isCameraActive: Bool
	var isTagsAlertActive: Bool

	var editingPhoto: PhotoViewModel? {
		get {
			getPhoto(photos, editingPhotoId)
		}
		set {
			set(newValue, onto: &photos)
		}
	}
}

public enum EditPhotosRightSideAction {
	case didTouchTag
	case didTouchPrivacy
	case didTouchTrash
	case didTouchCamera
}

struct EditPhotosRightSide: View {
	let store: Store<EditPhotosRightSideState, EditPhotosRightSideAction>
	var body: some View {
		WithViewStore(store.stateless) { viewStore in
			VStack {
				Spacer()
				Button(action: { viewStore.send(.didTouchTag)}, label: {
					Image(systemName: "tag")
				})
				Button(action: { viewStore.send(.didTouchPrivacy)}, label: {
					Image(systemName: "eye.slash")
				})
				Button(action: { viewStore.send(.didTouchTrash)}, label: {
					Image(systemName: "trash.circle.fill")
				})
				Button(action: { viewStore.send(.didTouchCamera)}, label: {
					Image(systemName: "camera.circle.fill")
				})
			}.buttonStyle(CameraButtonStyle())
		}
	}
}
