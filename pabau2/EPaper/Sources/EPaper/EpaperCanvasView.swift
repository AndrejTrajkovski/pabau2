import SwiftUI
import PencilKit

struct EpaperCanvasView: View {
    @State var canvasView: PKCanvasView
    @State var onSaved: () -> Void
}

extension EpaperCanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 1)
        canvasView.backgroundColor = UIColor.clear
        canvasView.isScrollEnabled = false
        
        // used for testing; it's not showing drawing on simulator without this
        #if targetEnvironment(simulator)
            canvasView.drawingPolicy = .anyInput
        #endif
        
        canvasView.delegate = context.coordinator
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var canvasView: Binding<PKCanvasView>
        let onSaved: () -> Void
        
        init(canvasView: Binding<PKCanvasView>, onSaved: @escaping () -> Void) {
            self.canvasView = canvasView
            self.onSaved = onSaved
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            if !canvasView.drawing.bounds.isEmpty {
                onSaved()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $canvasView, onSaved: onSaved)
    }
    
}
