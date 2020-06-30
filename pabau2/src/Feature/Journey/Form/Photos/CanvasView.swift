import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasView: UIViewControllerRepresentable {
	let store: Store<PhotoViewModel, PhotoAndCanvasAction>

	func makeUIViewController(context: Context) -> DrawingViewController {
		let drawinVC = DrawingViewController(viewStore: ViewStore(store))
		return drawinVC
	}

	func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
		uiViewController.updateViewStore(viewStore: ViewStore(store))
	}
}
