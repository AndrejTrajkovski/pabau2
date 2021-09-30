import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasViewState: Equatable {
    var photoId: PhotoViewModel.ID
	var drawing: Data
    var activeCanvas: CanvasMode
    var isDeletePhotoAlertActive: Bool
    
    func shouldReceiveTouches() -> Bool {
        activeCanvas == .drawing && (isDeletePhotoAlertActive == false)
    }
}

struct CanvasView: UIViewRepresentable {
	let store: Store<CanvasViewState, PhotoAndCanvasAction>

    struct CanvasViewViewState: Equatable {
        var photoId: PhotoViewModel.ID
        var shouldReceiveTouches: Bool
    }

	@ObservedObject var viewStore: ViewStore<CanvasViewViewState, PhotoAndCanvasAction>

	init(store: Store<CanvasViewState, PhotoAndCanvasAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(
                state: { CanvasViewViewState(photoId: $0.photoId,
                                             shouldReceiveTouches: $0.shouldReceiveTouches())
                },
                action: { $0 }
            ))
	}

	func makeUIView(context: Context) -> PKCanvasView {
        print("make ui view")
		let canvasView = PKCanvasView()
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.addObserver(canvasView)
            toolPicker.setVisible(viewStore.state.shouldReceiveTouches, forFirstResponder: canvasView)
		}
        canvasView.isUserInteractionEnabled = viewStore.state.shouldReceiveTouches

		canvasView.isScrollEnabled = false
		canvasView.becomeFirstResponder()
		canvasView.backgroundColor = UIColor.clear
		canvasView.isOpaque = false
		canvasView.delegate = context.coordinator

        do {
            canvasView.drawing = try PKDrawing(data: ViewStore(store).drawing)
        } catch {
            print("pkdrawing error")
            print(error)
        }


//		canvasView.delegate = self
		return canvasView
	}

	func updateUIView(_ canvasView: PKCanvasView, context: Context) {
 		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(viewStore.state.shouldReceiveTouches, forFirstResponder: canvasView)
            do {
                canvasView.drawing = try PKDrawing(data: ViewStore(store).drawing)
            } catch {
                print("pkdrawing error")
                print(error)
            }
		}
        canvasView.isUserInteractionEnabled = viewStore.state.shouldReceiveTouches
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
		var viewStore: ViewStore<CanvasViewViewState, PhotoAndCanvasAction>
		init(_ parent: CanvasView,
				 viewStore: ViewStore<CanvasViewViewState, PhotoAndCanvasAction>) {
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
        if viewStore.state.shouldReceiveTouches {
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
                let toolPicker = PKToolPicker.shared(for: window),
                toolPicker.isVisible {
                print("send action .onDrawingChange")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self.viewStore.send(.onDrawingChange(canvasView.drawing.dataRepresentation()))
//                }
            }
        }
	}
}
