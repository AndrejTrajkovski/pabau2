import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasViewState: Equatable {
	var drawing: Data
    var activeCanvas: CanvasMode
    var isDeletePhotoAlertActive: Bool
    
    func shouldReceiveTouches() -> Bool {
        activeCanvas == .drawing && (isDeletePhotoAlertActive == false)
    }
}

struct CanvasView: UIViewRepresentable {
	let store: Store<CanvasViewState, PhotoAndCanvasAction>
	@ObservedObject var viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>

	init(store: Store<CanvasViewState, PhotoAndCanvasAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(
                state: { $0 },
                action: { $0 }
            ))
	}

	func makeUIView(context: Context) -> PKCanvasView {
        print("make ui view")
		let canvasView = PKCanvasView()
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.addObserver(canvasView)
            toolPicker.setVisible(viewStore.state.shouldReceiveTouches(), forFirstResponder: canvasView)
		}
        canvasView.isUserInteractionEnabled = viewStore.state.shouldReceiveTouches()
		canvasView.isScrollEnabled = false
		canvasView.becomeFirstResponder()
		canvasView.backgroundColor = UIColor.clear
		canvasView.isOpaque = false
		canvasView.delegate = context.coordinator
//		canvasView.delegate = self
		return canvasView
	}

	func updateUIView(_ canvasView: PKCanvasView, context: Context) {
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(viewStore.state.activeCanvas == .drawing, forFirstResponder: canvasView)
            do {
                canvasView.drawing = try PKDrawing(data: viewStore.state.drawing)
            } catch {
                print("pkdrawing error")
                print(error)
            }
		}
        canvasView.isUserInteractionEnabled = viewStore.state.shouldReceiveTouches()
        print("canvasView.isUserInteractionEnabled : \(canvasView.isUserInteractionEnabled)")
//		uiViewController.updateViewStore(viewStore: viewStore)
        context.coordinator.viewStore = viewStore
	}

	static func dismantleUIView(_ canvasView: PKCanvasView, coordinator: Coordinator) {
		canvasView.delegate = nil
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.setVisible(false, forFirstResponder: canvasView)
			toolPicker.removeObserver(canvasView)
		}
		print("dismantle view")
	}

	class Coordinator: NSObject, PKCanvasViewDelegate {
		let parent: CanvasView
		var viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>
		init(_ parent: CanvasView,
				 viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>) {
			self.parent = parent
			self.viewStore = viewStore
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(self, viewStore: viewStore)
	}
}

extension CanvasView.Coordinator {
	func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print("canvasViewDrawingDidChange")
        if viewStore.state.shouldReceiveTouches() {
            
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
                let toolPicker = PKToolPicker.shared(for: window),
                toolPicker.isVisible {
                print("send action .onDrawingChange")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.viewStore.send(.onDrawingChange(canvasView.drawing.dataRepresentation()))
                }
            }
        }
	}
}
