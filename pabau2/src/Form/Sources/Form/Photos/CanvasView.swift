import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasViewState: Equatable {
	var photo: PhotoViewModel
	var isDisabled: Bool
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
			), removeDuplicates: { lhs, rhs in
				lhs.photo.id == rhs.photo.id &&
				lhs.isDisabled == rhs.isDisabled
		})
	}

	func makeUIView(context: Context) -> PKCanvasView {
        print("make ui view")
		let canvasView = PKCanvasView()
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.addObserver(canvasView)
			toolPicker.setVisible(!viewStore.state.isDisabled, forFirstResponder: canvasView)
		}
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
			toolPicker.setVisible(!viewStore.state.isDisabled, forFirstResponder: canvasView)
            canvasView.drawing = viewStore.state.photo.drawing
		}
//		uiViewController.updateViewStore(viewStore: viewStore)
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
		let viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>
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
		viewStore.send(.onDrawingChange(canvasView.drawing))
	}
}
