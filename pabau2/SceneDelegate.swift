import UIKit
import SwiftUI
import PageControl
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	let titles = [""]
	let descriptions = ["Managing your practice just got a whole lot easier",
											"Simplify your patient flow with our journey feature",
											"The future of digital consent at your hands",
											"Manage your schedule a patient history with ease"]
	let images = ["illu-walkthrough-1",
								"illu-walkthrough-2",
								"illu-walkthrough-3",
								"illu-walkthrough-4"]
	var window: UIWindow?
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		let contentView = PageView(
			images.map { Image.init($0) }
		)
		if let windowScene = scene as? UIWindowScene {
			let window = UIWindow(windowScene: windowScene)
			window.rootViewController = UIHostingController(rootView: contentView)
			self.window = window
			window.makeKeyAndVisible()
		}
	}
}
