import UIKit
import PencilKit

class DrawingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

	@IBOutlet weak var canvasView: PKCanvasView!
	@IBOutlet weak var pencilFingerBarButtonItem: UIBarButtonItem!
	@IBOutlet var undoBarButtonitem: UIBarButtonItem!
	@IBOutlet var redoBarButtonItem: UIBarButtonItem!

	/// Standard amount of overscroll allowed in the canvas.
	static let canvasOverscrollHeight: CGFloat = 500

	/// Data model for the drawing displayed by this view controller.
//	var dataModelController: DataModelController!

	/// Private drawing state.
	var drawingIndex: Int = 0
	var hasModifiedDrawing = false

	// MARK: View Life Cycle

	/// Set up the drawing initially.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Set up the canvas view with the first drawing from the data model.
		canvasView.delegate = self
//		canvasView.drawing = dataModelController.drawings[drawingIndex]
		canvasView.allowsFingerDrawing = true
		canvasView.isScrollEnabled = false
		canvasView.minimumZoomScale = 1.0
    canvasView.maximumZoomScale = 1.0
    canvasView.bounces = false
    canvasView.bouncesZoom = false

		// Set up the tool picker, using the window of our parent because our view has not
		// been added to a window yet.
		if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.setVisible(true, forFirstResponder: canvasView)
			toolPicker.addObserver(canvasView)
			toolPicker.addObserver(self)

			updateLayout(for: toolPicker)
			canvasView.becomeFirstResponder()
		}

		// Always show a back button.
		navigationItem.leftItemsSupplementBackButton = true
	}

	/// When the view is resized, adjust the canvas scale so that it is zoomed to the default `canvasWidth`.
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}

	/// When the view is removed, save the modified drawing, if any.
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Update the drawing in the data model, if it has changed.
		if hasModifiedDrawing {
//			dataModelController.updateDrawing(canvasView.drawing, at: drawingIndex)
		}

		// Remove this view controller as the screenshot delegate.
		view.window?.windowScene?.screenshotService?.delegate = nil
	}

	/// Hide the home indicator, as it will affect latency.
	override var prefersHomeIndicatorAutoHidden: Bool {
		return true
	}

	// MARK: Actions

	/// Action method: Turn finger drawing on or off.
	@IBAction func toggleFingerPencilDrawing(_ sender: Any) {
		canvasView.allowsFingerDrawing.toggle()
		pencilFingerBarButtonItem.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
	}

	/// Helper method to set a new drawing, with an undo action to go back to the old one.
	func setNewDrawingUndoable(_ newDrawing: PKDrawing) {
		let oldDrawing = canvasView.drawing
		undoManager?.registerUndo(withTarget: self) {
			$0.setNewDrawingUndoable(oldDrawing)
		}
		canvasView.drawing = newDrawing
	}

	// MARK: Canvas View Delegate

	/// Delegate method: Note that the drawing has changed.
	func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		hasModifiedDrawing = true
//		updateContentSizeForDrawing()
	}
	// MARK: Tool Picker Observer

	/// Delegate method: Note that the tool picker has changed which part of the canvas view
	/// it obscures, if any.
	func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
		updateLayout(for: toolPicker)
	}

	/// Delegate method: Note that the tool picker has become visible or hidden.
	func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
		updateLayout(for: toolPicker)
	}

	/// Helper method to adjust the canvas view size when the tool picker changes which part
	/// of the canvas view it obscures, if any.
	///
	/// Note that the tool picker floats over the canvas in regular size classes, but docks to
	/// the canvas in compact size classes, occupying a part of the screen that the canvas
	/// could otherwise use.
	func updateLayout(for toolPicker: PKToolPicker) {
		let obscuredFrame = toolPicker.frameObscured(in: view)

		// If the tool picker is floating over the canvas, it also contains
		// undo and redo buttons.
		if obscuredFrame.isNull {
			canvasView.contentInset = .zero
			navigationItem.leftBarButtonItems = []
		}

			// Otherwise, the bottom of the canvas should be inset to the top of the
			// tool picker, and the tool picker no longer displays its own undo and
			// redo buttons.
		else {
			canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxY - obscuredFrame.minY, right: 0)
			navigationItem.leftBarButtonItems = [undoBarButtonitem, redoBarButtonItem]
		}
		canvasView.scrollIndicatorInsets = canvasView.contentInset
	}
}
