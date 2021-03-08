import SwiftUI
import PencilKit
import ComposableArchitecture
import Form

public struct CanvasViewState: Equatable, Identifiable {
    public var photo: PhotoViewModel
    var isDisabled: Bool
    public var id: UUID
    public var canvas: PKCanvasView

    public init(uuid: UUID = UUID(), photo: PhotoViewModel, isDisabled: Bool, canvas: PKCanvasView = PKCanvasView()) {
        self.photo = photo
        self.isDisabled = isDisabled
        self.id = uuid
        self.canvas = canvas
    }
}

public struct CanvasEnvironment {
    public init() {}
}

public let canvasStateReducer = Reducer<CanvasViewState, PhotoAndCanvasAction, CanvasEnvironment>.init { state, action, env in
    switch action {
    case .onDrawingChange(let drawing):
        state.canvas.drawing = drawing
    case .onSave:
        break
    }
    return .none
}

public struct CanvasView: UIViewRepresentable {
    let store: Store<CanvasViewState, PhotoAndCanvasAction>
    @ObservedObject var viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>
    private let picker = PKToolPicker.init()

    public init(store: Store<CanvasViewState, PhotoAndCanvasAction>) {
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

    public func makeUIView(context: Context) -> CanvasViewWrapper {
        print("makeUIView")
        let canvasWrapper = CanvasViewWrapper(canvas: PKCanvasView())
        picker.addObserver(canvasWrapper.canvasView)
        picker.setVisible(!viewStore.state.isDisabled, forFirstResponder: canvasWrapper.canvasView)
        DispatchQueue.main.async {
            canvasWrapper.canvasView.becomeFirstResponder()
        }
        canvasWrapper.canvasView.isScrollEnabled = false
        canvasWrapper.canvasView.becomeFirstResponder()
        canvasWrapper.canvasView.backgroundColor = UIColor.clear
        canvasWrapper.canvasView.isOpaque = false
        canvasWrapper.canvasView.delegate = context.coordinator
        return canvasWrapper
    }

    public func updateUIView(_ canvasViewWrapper: CanvasViewWrapper, context: Context) {
        let canvas = viewStore.canvas
        canvasViewWrapper.canvasView.drawing = canvas.drawing
    }

    public static func dismantleUIView(_ canvasViewWrapper: CanvasViewWrapper, coordinator: Coordinator) {
        canvasViewWrapper.canvasView.delegate = nil
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(false, forFirstResponder: canvasViewWrapper)
            toolPicker.removeObserver(canvasViewWrapper.canvasView)
        }
        print("dismantle view")
    }

    public class Coordinator: NSObject, PKCanvasViewDelegate {
        let parent: CanvasView
        let viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>
        init(_ parent: CanvasView,
                 viewStore: ViewStore<CanvasViewState, PhotoAndCanvasAction>) {
            self.parent = parent
            self.viewStore = viewStore
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self, viewStore: viewStore)
    }
}

extension CanvasView.Coordinator {
    public func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        viewStore.send(.onDrawingChange(canvasView.drawing))
    }
}

public class CanvasViewWrapper: UIView {
    var canvasView: PKCanvasView
    public override init(frame: CGRect) {
        print("CanvasViewWrapper frame super init")
        canvasView = PKCanvasView()
        super.init(frame: frame)
        canvasView.frame = self.frame
        self.addSubview(canvasView)
    }

    init(canvas: PKCanvasView) {
        print("CanvasViewWrapper custom init")
        self.canvasView = canvas
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        canvasView.frame = self.frame
        self.addSubview(canvasView)
    }

    required init?(coder: NSCoder) {
        fatalError("CanvasViewWrapper init")
    }
}
