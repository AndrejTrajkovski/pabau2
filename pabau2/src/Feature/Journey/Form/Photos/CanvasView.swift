import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasView: UIViewRepresentable {
	@Binding var drawing: PKDrawing?
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

	func updateUIView(_ canvasView: PKCanvasView,
										context: UIViewRepresentableContext<CanvasView>) {
		if let drawing = drawing {
			if canvasView.drawing != drawing {
				canvasView.drawing = drawing
			}
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
		return Coordinator(self)
	}
	
	public class Coordinator: NSObject {
		let parent: CanvasView
		init(_ parent: CanvasView) {
			self.parent = parent
		}
	}
}

extension CanvasView.Coordinator: PKCanvasViewDelegate {
	public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		parent.drawing = canvasView.drawing
	}
}

extension CanvasView.Coordinator: PKToolPickerObserver {
}
