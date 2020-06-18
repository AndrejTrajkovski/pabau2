import SwiftUI
import PencilKit
import ComposableArchitecture

let editSinglePhotoReducer = Reducer<PhotoViewModel, EditSinglePhotoAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .onSave:
		break
	case .onDrawingChange(let drawing):
		state.drawing = drawing
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
	var body: some View {
		WithViewStore(store) { viewStore in
			ZStack {
				PhotoCell(photo: viewStore.state.photo, isSelected: false)
				CanvasView(drawing: viewStore.binding(
					get: { ($0.photo.drawing ?? PKDrawing()) }, send: EditSinglePhotoAction.onDrawingChange)
				)
			}
		}
	}
}
