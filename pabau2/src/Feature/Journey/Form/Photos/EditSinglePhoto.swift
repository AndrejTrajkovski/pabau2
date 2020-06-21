import SwiftUI
import PencilKit
import ComposableArchitecture

let editSinglePhotoReducer = Reducer<EditSinglePhotoState, EditSinglePhotoAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .onSave:
		break
	case .onDrawingChange(let drawing):
		state.photo.drawing = drawing
	}
	return .none
}

struct EditSinglePhotoState: Equatable {
	var photo: PhotoViewModel
}

public enum EditSinglePhotoAction: Equatable {
	case onSave
	case onDrawingChange(PKDrawing)
}

struct EditSinglePhoto: View {
	let store: Store<EditSinglePhotoState, EditSinglePhotoAction>
	init (store: Store<EditSinglePhotoState, EditSinglePhotoAction>) {
		self.store = store
	}

	@State var photoSize: CGSize = .zero
	var body: some View {
		print("edit single photo body")
		return ZStack {
			PhotoCell(photo: ViewStore(store).state.photo)
				.background(PhotoSizePreferenceSetter())
				.onPreferenceChange(PhotoSize.self) { size in
					self.photoSize = size
			}.layoutPriority(1)
			CanvasParent(store: self.store.scope(state: { $0.photo }))
				.frame(width: photoSize.width,
							 height: photoSize.height)
		}
	}
}

struct CanvasParent: View {
	let store: Store<PhotoViewModel, EditSinglePhotoAction>
	@ObservedObject var viewStore: ViewStore<PhotoViewModel, EditSinglePhotoAction>

	init(store: Store<PhotoViewModel, EditSinglePhotoAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		CanvasView(drawing:
			Binding<PKDrawing?>.init(
				get: { return self.viewStore.state.drawing },
				set: {
					guard let drawing = $0 else { return }
					self.viewStore.send(.onDrawingChange(drawing))
				}
			)
		)
	}
}

struct PhotoSizePreferenceSetter: View {
	var body: some View {
		GeometryReader { geometry in
			Color.clear
				.preference(key: PhotoSize.self,
										value: geometry.size)
		}
	}
}

struct PhotoSize: PreferenceKey {
	typealias Value = CGSize
	static var defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}
