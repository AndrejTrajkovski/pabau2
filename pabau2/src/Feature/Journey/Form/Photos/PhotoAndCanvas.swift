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
	init (store: Store<PhotoViewModel, PhotoAndCanvasAction>) {
		self.store = store
	}

	//TODO: UNCOMMENT CODE FOR EQUAL SIZES
	//TODO: FIX MEMORY LEAKS WITH PKDRAWINGS
	@State var photoSize: CGSize = .zero
	var body: some View {
		print("edit single photo body")
		return ZStack {
			PhotoCell(photo: ViewStore(store).state)
//				.background(PhotoSizePreferenceSetter())
//				.onPreferenceChange(PhotoSize.self) { size in
//					self.photoSize = size
//			}.layoutPriority(1)
			CanvasParent(store: self.store.scope(state: { $0 }))
//				.frame(width: photoSize.width,
//							 height: photoSize.height)
		}
	}
}

struct CanvasParent: View {
	let store: Store<PhotoViewModel, PhotoAndCanvasAction>
	@ObservedObject var viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>

	init(store: Store<PhotoViewModel, PhotoAndCanvasAction>) {
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
