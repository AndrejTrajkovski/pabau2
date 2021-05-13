import UIKit
import SwiftUI
import ComposableArchitecture
import Util
import Model
import Journey
import Clients
import SwiftDate
import Intercom
import FacebookShare
import CoreDataModel

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
    
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        Intercom.setApiKey(
            "ios_sdk-f223a9e3f380f60354bc459db9d5c0349c61fd7c",
             forAppId: "m3fk3gh1"
        )
        
        //CDStorage.shared.initialized()

		SwiftDate.defaultRegion = Region.UTC
		if let windowScene = scene as? UIWindowScene {
			let reducer = appReducer
//				.debug()
      let window = UIWindow(windowScene: windowScene)
			let userDefaults = StandardUDConfig()
			let user = userDefaults.loggedInUser
			let hasSeenWalkthrough = userDefaults.hasSeenAppIntroduction
			let apiClient = APIClient(baseUrl: "https://ios.pabau.me", loggedInUser: user)
            
            let storage = PabauStorage()
            storage.initialized()
            
            let repository = Repository(
                journeyAPI: apiClient,
                clientAPI: apiClient,
                formAPI: apiClient,
                userDefaults: userDefaults,
                coreDataModel: storage
            )
            
			let env = AppEnvironment(
				loginAPI: apiClient,
				journeyAPI: apiClient,
				clientsAPI: apiClient,
				formAPI: apiClient,
				userDefaults: userDefaults,
                repository: repository
			)
            
			window.rootViewController = UIHostingController(
				rootView: ContentView(
					store: Store(
						initialState: AppState(loggedInUser: nil,
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

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }

}
