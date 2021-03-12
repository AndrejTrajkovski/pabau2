import SwiftUI
import PencilKit
import ComposableArchitecture
import Form

public struct CanvasEnvironment {
    public init() {}
}

let canvasStateReducer = Reducer<CanvasViewState, PhotoAndCanvasAction, CanvasEnvironment>.init { state, action, env in
    switch action {
    case .onDrawingChange(let drawing):
        state.canvasDrawingState.canvasView.drawing = drawing
    case .onSave:
        break
    }
    
    return .none
}
