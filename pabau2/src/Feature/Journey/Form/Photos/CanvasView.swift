import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasView: UIViewControllerRepresentable {
	
	let store: Store<PhotoViewModel, PhotoAndCanvasAction>
	@ObservedObject var viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>
	let isDrawingEnabled: Bool
	
	init(store: Store<PhotoViewModel, PhotoAndCanvasAction>,
			 isDrawingEnabled: Bool) {
		self.isDrawingEnabled = isDrawingEnabled
		self.store = store
		self.viewStore = ViewStore(self.store.scope(
				state: { $0 },
				action: { $0 })
			, removeDuplicates: { lhs, rhs in
			lhs.id == rhs.id
		})
	}

	func makeUIViewController(context: Context) -> DrawingViewController {
		let drawinVC = DrawingViewController(viewStore: viewStore)
		return drawinVC
	}

	func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
		uiViewController.updateViewStore(viewStore: viewStore,
		isDrawingEnabled: isDrawingEnabled)
	}
}
