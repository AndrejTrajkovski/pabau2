import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasView: UIViewRepresentable {
	
	let store: Store<PhotoViewModel, PhotoAndCanvasAction>
	@ObservedObject var viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>
	
	init(store: Store<PhotoViewModel, PhotoAndCanvasAction>) {
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(
				state: { $0 },
				action: { $0 })
			, removeDuplicates: { lhs, rhs in
			lhs.id == rhs.id
		})
	}
	
	func makeUIView(context: Context) -> PKCanvasView {
		let canvasView = PKCanvasView()
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.addObserver(canvasView)
			toolPicker.setVisible(true, forFirstResponder: canvasView)
		}
		canvasView.isScrollEnabled = false
		canvasView.becomeFirstResponder()
		canvasView.backgroundColor = UIColor.clear
		canvasView.isOpaque = false
		canvasView.delegate = context.coordinator
//		canvasView.delegate = self
		return canvasView
	}

	func updateUIView(_ uiView: PKCanvasView, context: Context) {
		uiView.drawing = viewStore.state.drawing
//		uiViewController.updateViewStore(viewStore: viewStore)
	}

	static func dismantleUIView(_ uiView: PKCanvasView, coordinator: Coordinator) {
	
	}
	
	class Coordinator: NSObject, PKCanvasViewDelegate {
		let parent: CanvasView
		let viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>
		init(_ parent: CanvasView,
				 viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>) {
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
		viewStore.send(.onDrawingChange(canvasView.drawing))
	}
}
