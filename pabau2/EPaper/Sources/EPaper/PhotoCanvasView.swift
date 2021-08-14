import SwiftUI
import SDWebImageSwiftUI
import PencilKit
import ComposableArchitecture
import Combine

public enum PhotoAndCanvasAction: Equatable {
    case onSave
    case onDrawingChange(Data)
    case imageDownloaded(UIImage)
    case mergeWithDrawing
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
    static func == (lhs: CanvasViewState, rhs: CanvasViewState) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let imageURL: String
    var isDisabled: Bool
    var canvasDrawingState: CanvasDrawingState = CanvasDrawingState(canvasView: PKCanvasView())
     
    var uiImage: UIImage = UIImage()
    var mergeImage: UIImage = UIImage()
    
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
            VStack {
                ZStack {
                    WebImage(url: URL(string: viewStore.state.imageURL)!)
                        .onSuccess(perform: { (uiImage, _, _) in
                            viewStore.send(.imageDownloaded(uiImage))
                        })
                        .indicator(.activity)
                    EpaperCanvasView(store: store)
                }
            }
        }
    }
}
