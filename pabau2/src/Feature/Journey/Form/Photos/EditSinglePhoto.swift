import SwiftUI
import PencilKit

struct EditSinglePhotoState {
	let photo: Photo
	var drawings: [PKDrawing]
}

struct EditSinglePhoto: View {
	var body: some View {
		CanvasView()
	}
}

struct CanvasView: UIViewRepresentable {
	
	func makeUIView(context: UIViewRepresentableContext<CanvasView>) -> PKCanvasView {
		let canvasView = PKCanvasView()
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.addObserver(canvasView)
			toolPicker.addObserver(context.coordinator)
			toolPicker.setVisible(true, forFirstResponder: canvasView)
    }
		canvasView.becomeFirstResponder()
		return canvasView
	}
	
	func updateUIView(_ uiView: PKCanvasView, context: UIViewRepresentableContext<CanvasView>) {
		
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
	
}

extension CanvasView.Coordinator: PKToolPickerObserver {
	
}
