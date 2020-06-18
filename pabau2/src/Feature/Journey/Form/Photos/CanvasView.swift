import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
	
	@Binding var drawing: PKDrawing

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
		return canvasView
	}

	func updateUIView(_ canvasView: PKCanvasView, context: UIViewRepresentableContext<CanvasView>) {
		canvasView.drawing = drawing
	}

	/// Cleans up the presented `UIView` (and coordinator) in
	/// anticipation of their removal.
	static func dismantleUIView(_ uiView: PKCanvasView, coordinator: Coordinator) {
	}
	
	public func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	public class Coordinator: NSObject {
		var parent: CanvasView

		init(_ parent: CanvasView) {
			self.parent = parent
		}
	}
}

extension CanvasView.Coordinator: PKCanvasViewDelegate {
	public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		self.parent.drawing = canvasView.drawing
	}
}

extension CanvasView.Coordinator: PKToolPickerObserver {
	
}
