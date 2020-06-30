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
		if state.chosenInjectableId == nil {
			state.isChooseInjectablesActive = true
		}
	case .didTouchPencil:
		state.activeCanvas = .drawing
	}
	return .none
}

public struct EditPhotosRightSideState: Equatable {
	var photos: IdentifiedArrayOf<PhotoViewModel>
	var editingPhotoId: PhotoVariantId?
	var isCameraActive: Bool
	var isTagsAlertActive: Bool
	var activeCanvas: CanvasMode
	var isChooseInjectablesActive: Bool
	var chosenInjectableId: InjectableId?
	
	var editingPhoto: PhotoViewModel? {
		get {
			getPhoto(photos, editingPhotoId)
		}
		set {
			set(newValue, onto: &photos)
		}
	}
}

public enum EditPhotosRightSideAction: Equatable {
	case didTouchInjectables
	case didTouchTag
	case didTouchPrivacy
	case didTouchTrash
	case didTouchCamera
	case didTouchPencil
}

struct EditPhotosRightSide: View {
	let store: Store<EditPhotosRightSideState, EditPhotosRightSideAction>
	@ObservedObject var viewStore: ViewStore<EditPhotosRightSideState, EditPhotosRightSideAction>
	
	init(store: Store<EditPhotosRightSideState, EditPhotosRightSideAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack {
			Spacer()
			VStack {
				Button(action: { self.viewStore.send(.didTouchTag)}, label: {
					Image(systemName: "tag.circle.fill")
				})
				Button(action: { self.viewStore.send(.didTouchPrivacy)}, label: {
					Image(systemName: "eye.slash.fill")
						.foregroundColor((self.viewStore.state.editingPhoto?.isPrivate ?? false) ? .blue : Color.gray184)
						.font(.system(size: 32))
				})
				Button(action: { self.viewStore.send(.didTouchTrash)}, label: {
					Image(systemName: "trash.circle.fill")
				})
				Button(action: { self.viewStore.send(.didTouchCamera)}, label: {
					Image(systemName: "camera.circle.fill")
						.foregroundColor(Color.blue)
						.font(.system(size: 44))
				})
			}
		Spacer()
			VStack {
				Button(action: { self.viewStore.send(.didTouchPencil) }, label: {
					Image(systemName: "pencil.tip.crop.circle")
						.foregroundColor(self.viewStore.state.activeCanvas == .drawing ? .blue : Color.gray184)
				})
				Button.init(action: {
					self.viewStore.send(.didTouchInjectables)
				}, label: {
					Image(self.viewStore.state.activeCanvas == .injectables ?
						"ico-journey-upload-photos-injectables" :
						"ico-journey-upload-photos-injectables-gray")
				})
			}
		}.buttonStyle(EditPhotosButtonStyle())
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
