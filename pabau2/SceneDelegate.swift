import UIKit
import SwiftUI
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		if let windowScene = scene as? UIWindowScene {
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: ContentView(
          store: Store(
						initialValue: AppState(loginNav: .walkthrough),
            reducer: with(
              appReducer,
							compose(
								logging,
								appLogin
							)
            )
          )
				).environmentObject(KeyboardFollower())
      )
      self.window = window
      window.makeKeyAndVisible()
    }
	}
}
