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

struct PhotoAndCanvas: View {
	let store: Store<PhotoViewModel, PhotoAndCanvasAction>
	init (store: Store<PhotoViewModel, PhotoAndCanvasAction>,
				_ photoSize: Binding<CGSize>) {
		self.store = store
		self._photoSize = photoSize
	}
	@Binding var photoSize: CGSize
	//TODO: UNCOMMENT CODE FOR EQUAL SIZES
	//TODO: FIX MEMORY LEAKS WITH PKDRAWINGS
	var body: some View {
		ZStack {
			PhotoCell(photo: ViewStore(store).state)
				.background(PhotoSizePreferenceSetter())
				.onPreferenceChange(PhotoSize.self) { size in
					print(size)
					self.photoSize = size
			}
			CanvasParent(store: self.store.scope(state: { $0 }))
				.frame(width: photoSize.width,
							 height: photoSize.height)
		}
	}
}

struct CanvasParent: View {
	let store: Store<PhotoViewModel, PhotoAndCanvasAction>
	@ObservedObject var viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>

	init(store: Store<PhotoViewModel, PhotoAndCanvasAction>) {
		self.store = store
		self.viewStore = ViewStore(store, removeDuplicates: { lhs, rhs in
			lhs.id == rhs.id
		})
	}

	var body: some View {
		CanvasView(store: store)
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
