import SwiftUI
import PencilKit
import ComposableArchitecture

let editSinglePhotoReducer = Reducer<EditSinglePhotoState, EditSinglePhotoAction, JourneyEnvironment>.init { state, action, env in
	switch action {
	case .onSave:
		break
	case .onDrawingChange(let drawing):
		state.drawing = drawing
	}
	return .none
}

struct EditSinglePhotoState: Equatable {
	let photo: Photo
	var drawing: PKDrawing
}

enum EditSinglePhotoAction: Equatable {
	case onSave
	case onDrawingChange(PKDrawing)
}

struct EditSinglePhoto: View {
	let store: Store<EditSinglePhotoState, EditSinglePhotoAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			ZStack {
				PhotoCell(photo: viewStore.state.photo)
				CanvasView(drawing: viewStore.binding(
					get: { $0.drawing }, send: EditSinglePhotoAction.onDrawingChange)
				)
			}
		}
	}
}
