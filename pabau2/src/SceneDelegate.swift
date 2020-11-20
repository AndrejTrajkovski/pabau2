import UIKit
import SwiftUI
import ComposableArchitecture
import Util
import Model
import Journey
import Clients
import SwiftDate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		SwiftDate.defaultRegion = Region.local
		if let windowScene = scene as? UIWindowScene {
			let reducer = appReducer
//				.debug()
      let window = UIWindow(windowScene: windowScene)
			let userDefaults = StandardUDConfig()
			let user = userDefaults.loggedInUser
			let hasSeenWalkthrough = userDefaults.hasSeenAppIntroduction
			let env = AppEnvironment(
				loginAPI: LoginMockAPI(delay: 1),
				journeyAPI: JourneyMockAPI(),
				clientsAPI: ClientsMockAPI(),
				userDefaults: userDefaults
			)
      window.rootViewController = UIHostingController(
		rootView: ContentView(
			store: Store(
				initialState: AppState(user: user,
									   hasSeenWalkthrough: hasSeenWalkthrough!
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
