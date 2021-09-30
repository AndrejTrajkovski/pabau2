import SwiftUI
import PencilKit
import ComposableArchitecture
import Util

let photoAndCanvasReducer = Reducer<PhotoViewModel, PhotoAndCanvasAction, FormEnvironment>.init { state, action, _ in
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
	case onDrawingChange(Data)
}

struct PhotoParent: View {
	let store: Store<PhotoViewModel, Never>
	@Binding var photoSize: CGSize

	init (store: Store<PhotoViewModel, Never>,
				_ photoSize: Binding<CGSize>) {
		self.store = store
		self._photoSize = photoSize
	}
    
    //using "preference key " in background() is not working https://developer.apple.com/forums/thread/668976
	var body: some View {
		PhotoCell(photo: ViewStore(store).state)
        ContainerView {
            PhotoSizePreferenceSetter()
        }.onPreferenceChange(PhotoSize.self) { size in
            self.photoSize = size
        }
	}
}

struct ContainerView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    var body: some View {
        content.isHidden(true)
    }
}

struct PhotoSizePreferenceSetter: View {
    var body: some View {
        GeometryReaderPatch { geometry in
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
