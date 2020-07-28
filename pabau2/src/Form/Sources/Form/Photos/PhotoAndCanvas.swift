import SwiftUI
import PencilKit
import ComposableArchitecture

let photoAndCanvasReducer = Reducer<PhotoViewModel, PhotoAndCanvasAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .onSave:
		break
	case .onDrawingChange(let drawing):
		state.drawing = drawing
	}
	return .none
}

public enum PhotoAndCanvasAction: Equatable {
	case onSave
	case onDrawingChange(PKDrawing)
}

struct PhotoParent: View {
	let store: Store<PhotoViewModel, Never>
	@Binding var photoSize: CGSize

	init (store: Store<PhotoViewModel, Never>,
				_ photoSize: Binding<CGSize>) {
		self.store = store
		self._photoSize = photoSize
	}

	var body: some View {
		PhotoCell(photo: ViewStore(store).state)
			.background(PhotoSizePreferenceSetter())
			.onPreferenceChange(PhotoSize.self) { size in
				print(size)
				self.photoSize = size
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
