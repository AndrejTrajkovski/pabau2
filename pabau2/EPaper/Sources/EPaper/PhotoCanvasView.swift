import SwiftUI
import SDWebImageSwiftUI
import PencilKit
import ComposableArchitecture

public enum PhotoAndCanvasAction: Equatable {
    case onSave
    case onDrawingChange(PKDrawing)
}

struct CanvasDrawingState: Equatable {
    let id: UUID
    var canvasView: PKCanvasView
    
    init(id: UUID = UUID(), canvasView: PKCanvasView) {
        self.id = id
        self.canvasView = canvasView
    }
}

struct CanvasViewState: Equatable, Identifiable {
    let id: UUID
    let imageURL: String
    var isDisabled: Bool
    var canvasDrawingState: CanvasDrawingState = CanvasDrawingState(canvasView: PKCanvasView())
        
    init(uuid: UUID = UUID(), imageURL: String, isDisabled: Bool) {
        self.isDisabled = isDisabled
        self.id = uuid
        self.imageURL = imageURL
    }
}

struct PhotoCanvasView: View {    
    let store: Store<CanvasViewState, PhotoAndCanvasAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                WebImage(url: URL(string: viewStore.state.imageURL)!)
                    .resizable()
                EpaperCanvasView(store: store)
            }
        }
    }
}
