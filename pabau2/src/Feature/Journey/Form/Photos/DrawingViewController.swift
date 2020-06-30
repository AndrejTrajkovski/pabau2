import UIKit
import PencilKit
import ComposableArchitecture
import Combine

class DrawingViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

	public var viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>
	var cancellables: Set<AnyCancellable> = []
	
	init(viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>) {
		self.viewStore = viewStore
		super.init(nibName: nil, bundle: nil)
	}

	func updateViewStore(viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>) {
		self.viewStore = viewStore
		canvasView.drawing = viewStore.drawing ?? PKDrawing()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	weak var canvasView: PKCanvasView!
	var drawingIndex: Int = 0
	var hasModifiedDrawing = false

	override func viewDidLoad() {
		super.viewDidLoad()
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
		canvasView.drawing = self.viewStore.drawing ?? PKDrawing()
//		self.viewStore.publisher
//			.map { ($0.drawing ?? PKDrawing()) }
//			.assign(to: \.drawing, on: canvasView)
//			.store(in: &self.cancellables)
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
			toolPicker.addObserver(self)
			canvasView.becomeFirstResponder()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
	}
	
	override var prefersHomeIndicatorAutoHidden: Bool {
		return true
	}

	// MARK: Canvas View Delegate

	/// Delegate method: Note that the drawing has changed.
	func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
		viewStore.send(.onDrawingChange(canvasView.drawing))
//		updateContentSizeForDrawing()
	}
	// MARK: Tool Picker Observer
}
