import UIKit
import PencilKit
import ComposableArchitecture
import Combine

class DrawingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

	var viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>

	init(viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>) {
		self.viewStore = viewStore
		super.init(nibName: nil, bundle: nil)
	}

	func updateViewStore(viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>,
											 isDrawingEnabled: Bool) {
		canvasView.isUserInteractionEnabled = isDrawingEnabled
		self.viewStore = viewStore
		canvasView.drawing = viewStore.state.drawing
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	weak var canvasView: PKCanvasView!
	var drawingIndex: Int = 0
	var hasModifiedDrawing = false

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .clear
		let canvasView = PKCanvasView()
		view.addSubview(canvasView)
		if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.addObserver(canvasView)
			toolPicker.setVisible(true, forFirstResponder: canvasView)
		}
		canvasView.isScrollEnabled = false
		canvasView.becomeFirstResponder()
		canvasView.backgroundColor = UIColor.clear
		canvasView.isOpaque = false
		canvasView.delegate = self
		self.canvasView = canvasView
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		self.canvasView.frame = self.view.bounds
	}
	// MARK: View Life Cycle

	/// Set up the drawing initially.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.setVisible(true, forFirstResponder: canvasView)
			toolPicker.addObserver(canvasView)
			canvasView.becomeFirstResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
			toolPicker.removeObserver(canvasView)
		}
	}

	override var prefersHomeIndicatorAutoHidden: Bool {
		return true
	}

	// MARK: Canvas View Delegate
	func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		viewStore.send(.onDrawingChange(canvasView.drawing))
	}
	
	func who(_ any: Any) -> String {
			if Mirror(reflecting: any).displayStyle == .class {
					return "Class"
			} else {
					return "Struct"
			}
	}
}
