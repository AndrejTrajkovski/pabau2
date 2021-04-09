import SwiftUI
import PencilKit
import ComposableArchitecture

struct EpaperCanvasView: View {
    let store: Store<CanvasViewState, PhotoAndCanvasAction>
    @ObservedObject var viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>
    
    let toolPicker = PKToolPicker()
    let canvasView = PKCanvasView()
    
    init(store: Store<CanvasViewState, PhotoAndCanvasAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
}

extension EpaperCanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = UIColor.clear
        canvasView.isScrollEnabled = false
        
        toolPicker.selectedTool = PKInkingTool(.pen, color: .black, width: 1)
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(!viewStore.isDisabled, forFirstResponder: canvasView)
        DispatchQueue.main.async {
            canvasView.becomeFirstResponder()
        }
        
        // used for testing; it's not showing drawing on simulator without this
        #if targetEnvironment(simulator)
            canvasView.drawingPolicy = .anyInput
        #endif
        
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = viewStore.canvasDrawingState.canvasView.drawing
    }
    
    static func dismantleUIView(_ uiView: PKCanvasView, coordinator: Coordinator) { }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
        let parent: EpaperCanvasView
        let viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>
        init(_ parent: EpaperCanvasView, viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>) {
            self.parent = parent
            self.viewStore = viewStore
        }
        
        func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
            parent.canvasView.tool = toolPicker.selectedTool
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewStore: viewStore)
    }
    
}

extension EpaperCanvasView.Coordinator {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if !canvasView.drawing.bounds.isEmpty {
            viewStore.send(.onDrawingChange(canvasView.drawing))
        }
    }
}
