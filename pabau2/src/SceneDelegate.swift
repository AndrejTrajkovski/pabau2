import UIKit
import SwiftUI
import ComposableArchitecture
import Util
import Model
import Journey

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		if let windowScene = scene as? UIWindowScene {
//			let reducer = logging(appReducer)
			let reducer = appReducer
      let window = UIWindow(windowScene: windowScene)
			let userDefaults = StandardUDConfig()
			let env = AppEnvironment(
				loginAPI: LoginMockAPI(delay: 1),
				journeyAPI: JourneyMockAPI(),
				userDefaults: userDefaults
			)
      window.rootViewController = UIHostingController(
        rootView: ContentView(
          store: Store(
						initialValue: AppState(user: userDefaults.loggedInUser,
																	 hasSeenWalkthrough: userDefaults.hasSeenAppIntroduction
						),
						reducer: reducer,
						environment: env
          )
				).environmentObject(KeyboardFollower())
      )
      self.window = window
      window.makeKeyAndVisible()
    }
	}
}
