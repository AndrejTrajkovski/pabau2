import UIKit
import SwiftUI
import ComposableArchitecture
import Util
import Model
import Journey
import Clients
import SwiftDate
import Intercom

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        Intercom.setApiKey("ios_sdk-f223a9e3f380f60354bc459db9d5c0349c61fd7c",
                           forAppId: "m3fk3gh1")

		SwiftDate.defaultRegion = Region.UTC
		if let windowScene = scene as? UIWindowScene {
			let reducer = appReducer
//				.debug()
      let window = UIWindow(windowScene: windowScene)
			let userDefaults = StandardUDConfig()
			let user = userDefaults.loggedInUser
			let hasSeenWalkthrough = userDefaults.hasSeenAppIntroduction
			let env = AppEnvironment(
				loginAPI: LoginMockAPI(delay: 1),
				journeyAPI: JourneyLiveAPI(),
				clientsAPI: ClientsLiveAPI(),
				userDefaults: userDefaults
			)
      window.rootViewController = UIHostingController(
		rootView: ContentView(
			store: Store(
				initialState: AppState(loggedInUser: user,
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
