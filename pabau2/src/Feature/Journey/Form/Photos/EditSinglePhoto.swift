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
	var viewStore: ViewStore<EditSinglePhotoState, EditSinglePhotoAction>
	init (store: Store<EditSinglePhotoState, EditSinglePhotoAction>) {
		self.store = store
		self.viewStore = ViewStore(store, removeDuplicates: {
			$0.photo.id == $1.photo.id
		})
	}

	@State var photoSize: CGSize = .zero
	var body: some View {
		ZStack {
			PhotoCell(photo: viewStore.state.photo)
				.background(PhotoSizePreferenceSetter())
				.onPreferenceChange(PhotoSize.self) { size in
					self.photoSize = size
			}
			CanvasView(self.store.scope(state: { $0.photo },
																	action: { $0 }))
				.frame(width: photoSize.width,
							 height: photoSize.height)
		}
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
