import SwiftUI
import ComposableArchitecture
import Util

public let editPhotosRightSideReducer = Reducer<EditPhotosRightSideState, EditPhotosRightSideAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .didTouchTag:
		state.isTagsAlertActive = true
	case .didTouchPrivacy:
		state.editingPhoto?.isPrivate.toggle()
	case .didTouchTrash:
		guard let editingPhotoId = state.editingPhotoId else { break }
		let idx = state.photos.ids.firstIndex(where: { $0 == editingPhotoId }).map {
			Int($0)
		}!
		let toBeSelected = state.photos[safe: state.photos.index(after: idx)] ??
			state.photos[safe: state.photos.index(before: idx)]
		state.editingPhotoId = toBeSelected.map(\.id)
		state.photos.remove(id: editingPhotoId)
	case .didTouchCamera:
		state.isCameraActive = true
	case .didTouchInjectables:
		state.activeCanvas = .injectables
	}
	return .none
}

public struct EditPhotosRightSideState {
	var photos: IdentifiedArrayOf<PhotoViewModel>
	var editingPhotoId: PhotoVariantId?
	var isCameraActive: Bool
	var isTagsAlertActive: Bool
	var activeCanvas: CanvasMode
	
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
	case didTouchInjectables
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
				Button.init(action: {
					viewStore.send(.didTouchInjectables)
				}, label: {
					Image("ico-journey-upload-photos-injectables")
						.foregroundColor(.main)
				})
				Button(action: { viewStore.send(.didTouchTag)}, label: {
					Image(systemName: "tag.circle.fill")
				})
				Button(action: { viewStore.send(.didTouchPrivacy)}, label: {
					Image(systemName: "eye.slash.fill")
						.font(.system(size: 32))
				})
				Button(action: { viewStore.send(.didTouchTrash)}, label: {
					Image(systemName: "trash.circle.fill")
				})
				Button(action: { viewStore.send(.didTouchCamera)}, label: {
					Image(systemName: "camera.circle.fill")
						.foregroundColor(Color.blue)
						.font(.system(size: 44))
				})
			}.buttonStyle(EditPhotosButtonStyle())
		}
	}
}

struct EditPhotosButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.system(size: 40))
			.frame(width: 60, height: 60)
			.foregroundColor(Color.cameraImages)
			.background(Color.white)
			.clipShape(Circle())
	}
}
