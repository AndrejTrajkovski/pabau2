import SwiftUI
import PencilKit
import ComposableArchitecture
import Form

public struct CanvasEnvironment {
    public init() {}
}

let canvasStateReducer = Reducer<CanvasViewState, PhotoAndCanvasAction, CanvasEnvironment>.init { state, action, _ in
    switch action {
    case .onDrawingChange(let drawing):
        state.canvasDrawingState.canvasView.drawing = drawing
    case .onSave:
        break
    case .imageDownloaded(let uiImage):
        state.uiImage = uiImage
    case .mergeWithDrawing:
        let drawingRectSize = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let drawingImage = state.canvasDrawingState.canvasView.drawing.image(from: drawingRectSize, scale: 1.0)
        state.mergeImage = state.uiImage.mergeWith(topImage: drawingImage)
    }
    return .none
}
