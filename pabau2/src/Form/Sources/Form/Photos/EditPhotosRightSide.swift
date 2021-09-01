import SwiftUI
import ComposableArchitecture
import Util
import PencilKit

public let editPhotosRightSideReducer = Reducer<EditPhotosRightSideState, EditPhotosRightSideAction, FormEnvironment>.init { state, action, _ in
	switch action {
	case .didTouchTag:
		state.isTagsAlertActive = true
	case .didTouchPrivacy:
		state.photo?.isPrivate.toggle()
	case .didTouchTrash:
		break//parent
    case .deleteAlertCanceled:
        state.deletePhotoAlert = nil
	case .didTouchCamera:
		state.isCameraActive = true
	case .didTouchInjectables:
		if state.activeCanvas == .injectables {
			state.isChooseInjectablesActive = true
		} else if state.activeCanvas == .drawing {
			if state.chosenInjectableId == nil {
				state.isChooseInjectablesActive = true
			}
			state.activeCanvas = .injectables
		}
	case .didTouchPencil:
		state.activeCanvas = .drawing
	case .didTouchOpenPhotosLibrary:
		state.isPhotosAlbumActive = true
    case .deleteAlertConfirmed:
        break//parent
    }
	return .none
}

public struct EditPhotosRightSideState: Equatable {
	var photo: PhotoViewModel?
	var isCameraActive: Bool
	var isTagsAlertActive: Bool
	var activeCanvas: CanvasMode
	var isChooseInjectablesActive: Bool
	var chosenInjectableId: Int?
	var isPhotosAlbumActive: Bool
	var deletePhotoAlert: AlertState<EditPhotoAction>?

//	var editingPhoto: PhotoViewModel? {
//		get {
//			getPhoto(photos, editingPhotoId)
//		}
//		set {
//			set(newValue, onto: &photos)
//		}
//	}
}

public enum EditPhotosRightSideAction: Equatable {
	case didTouchInjectables
	case didTouchTag
	case didTouchPrivacy
	case didTouchTrash
	case didTouchCamera
	case didTouchPencil
	case didTouchOpenPhotosLibrary
	case deleteAlertConfirmed
	case deleteAlertCanceled
}

struct EditPhotosRightSide: View {
	let store: Store<EditPhotosRightSideState, EditPhotosRightSideAction>
	struct ViewState: Equatable {
		let isDeleteAlertActive: Bool
		let isChooseInjectablesActive: Bool
		let eyeIconColor: Color
		let pencilIconColor: Color
		init(state: EditPhotosRightSideState) {
			self.isDeleteAlertActive = state.deletePhotoAlert != nil
			self.isChooseInjectablesActive = true//state.activeCanvas == .injectables
			self.eyeIconColor = state.photo?.isPrivate ?? false ? .blue : Color.gray184
			self.pencilIconColor = state.activeCanvas == .drawing ? .blue : Color.gray184
		}
	}

	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			VStack {
				Button(action: { viewStore.send(.didTouchTrash)}, label: {
					Image(systemName: "trash.circle.fill")
				})
				Button(action: { viewStore.send(.didTouchPrivacy)}, label: {
					Image(systemName: "eye.slash.fill")
						.foregroundColor(viewStore.state.eyeIconColor)
						.font(.system(size: 32))
				})
				Button(action: { viewStore.send(.didTouchTag)}, label: {
					Image(systemName: "tag.circle.fill")
				})
				Spacer()
				Button.init(action: { viewStore.send(.didTouchOpenPhotosLibrary) }, label: {
					Image(systemName: "photo.on.rectangle")
						.foregroundColor(Color.blue)
						.font(.system(size: 32))
				})
				Button(action: { viewStore.send(.didTouchCamera)}, label: {
					Image(systemName: "camera.circle.fill")
						.foregroundColor(Color.blue)
						.font(.system(size: 44))
				})
				Spacer()
				Button(action: { viewStore.send(.didTouchPencil) }, label: {
					Image(systemName: "pencil.tip.crop.circle")
						.foregroundColor(viewStore.state.pencilIconColor)
				})
				Button.init(action: {
					viewStore.send(.didTouchInjectables)
				}, label: {
					Image(viewStore.state.isChooseInjectablesActive ?
						"ico-journey-upload-photos-injectables" :
						"ico-journey-upload-photos-injectables-gray")
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
