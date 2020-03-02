import UIKit
import SwiftUI
import ComposableArchitecture
import Util
import Model

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		if let windowScene = scene as? UIWindowScene {
			let reducer = logging(appReducer)
//			let reducer = with(
//				appReducer,
//				composed
//			)
      let window = UIWindow(windowScene: windowScene)
      window.rootViewController = UIHostingController(
        rootView: ContentView(
          store: Store(
						initialValue: AppState(navigation: .login([LoginNavScreen.walkthroughScreen])),
						reducer: reducer,
						environment: AppEnvironment(
							apiClient: MockAPIClient(),
							userDefaults: UserDefaults.standard
						)
          )
				).environmentObject(KeyboardFollower())
      )
      self.window = window
      window.makeKeyAndVisible()
    }
	}
}
