import SwiftUI
import PencilKit
import ComposableArchitecture

struct CanvasView: UIViewControllerRepresentable {
	@ObservedObject var viewStore: ViewStore<PhotoViewModel, PhotoAndCanvasAction>

	func makeUIViewController(context: Context) -> DrawingViewController {
		let drawinVC = DrawingViewController(viewStore: viewStore)
		return drawinVC
	}

	func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
		uiViewController.updateViewStore(viewStore: viewStore)
	}
}
