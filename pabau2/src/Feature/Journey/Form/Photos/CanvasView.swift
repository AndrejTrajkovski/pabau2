import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasView: UIViewRepresentable {

	let store: Store<PhotoViewModel, EditSinglePhotoAction>
	let viewStore: ViewStore<PhotoViewModel, EditSinglePhotoAction>
	init (_ store: Store<PhotoViewModel, EditSinglePhotoAction>) {
		self.store = store
		self.viewStore = ViewStore(store, removeDuplicates: {
			$0.id == $1.id
		})
	}

	func makeUIView(context: UIViewRepresentableContext<CanvasView>) -> PKCanvasView {
		let canvasView = PKCanvasView()
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.addObserver(canvasView)
			toolPicker.addObserver(context.coordinator)
			toolPicker.setVisible(true, forFirstResponder: canvasView)
		}
		canvasView.isScrollEnabled = false
		canvasView.becomeFirstResponder()
		canvasView.backgroundColor = UIColor.clear
		canvasView.isOpaque = false
		canvasView.delegate = context.coordinator
		return canvasView
	}

	func updateUIView(_ canvasView: PKCanvasView, context: UIViewRepresentableContext<CanvasView>) {
		if let drawing = viewStore.state.drawing {
			canvasView.drawing = drawing
		} else {
			canvasView.drawing = PKDrawing()
		}
	}

	/// Cleans up the presented `UIView` (and coordinator) in
	/// anticipation of their removal.
	static func dismantleUIView(_ canvasView: PKCanvasView, coordinator: Coordinator) {
		canvasView.delegate = nil
		canvasView.resignFirstResponder()
	}

	public func makeCoordinator() -> Coordinator {
		return Coordinator(viewStore)
	}

	public class Coordinator: NSObject {
		var viewStore: ViewStore<PhotoViewModel, EditSinglePhotoAction>

		init(_ viewStore: ViewStore<PhotoViewModel, EditSinglePhotoAction>) {
			self.viewStore = viewStore
		}
	}
}

extension CanvasView.Coordinator: PKCanvasViewDelegate {
	public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//		self.viewStore.send(.onDrawingChange(canvasView.drawing))
	}
}

extension CanvasView.Coordinator: PKToolPickerObserver {
}
