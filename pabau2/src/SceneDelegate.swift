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
import TextLog
import Form
import Journey

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    static func makeDebugEnv() -> DebugEnvironment {
//        #if DEBUG
//        return DebugEnvironment.init(printer: { _ in })
//        #else
        return DebugEnvironment.init(printer: { logMessage in
            var log = TextLog()
//            log.write(logMessage)
        })
//        #endif
    }
    
	var window: UIWindow?
    
	func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        Intercom.setApiKey(
            "ios_sdk-f223a9e3f380f60354bc459db9d5c0349c61fd7c",
             forAppId: "m3fk3gh1"
        )
        
		SwiftDate.defaultRegion = Region(calendar: Calendar.gregorian,
										 zone: Zones.gmt,
										 locale: Locale.init(identifier: "en_US_POSIX"))
		if let windowScene = scene as? UIWindowScene {
            let reducer = appReducer.debug(environment: { $0.debug })
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
          
            let debugEnv = Self.makeDebugEnv()
            
			let env = AppEnvironment(
				loginAPI: apiClient,
				journeyAPI: apiClient,
				clientsAPI: apiClient,
				formAPI: apiClient,
				userDefaults: userDefaults,
                repository: repository,
				audioPlayer: AudioPlayer(),
                debug: debugEnv
			)
            
            let contentView = ContentView(
                store: Store(
                    initialState: AppState(
                        loggedInUser: nil,
                        hasSeenWalkthrough: hasSeenWalkthrough!
                    ),
                    reducer: reducer,
                    environment: env
                )
            ).environmentObject(KeyboardFollower())
            
            window.rootViewController = UIHostingController(
                rootView: contentView
//                rootView: makeMockPhotosStep(appEnv: env)
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

func makeMockPhotosStep(appEnv: AppEnvironment) -> some View {
    let step = Step(id: Step.ID.init(rawValue: 8225),
                    stepType: .photos,
                    preselectedTemplate: nil,
                    canSkip: true)

    let stepAndEntry = StepAndStepEntry(step: step, entry: nil)
    let stepState = StepState.init(stepAndEntry: stepAndEntry,
                                   clientId: Client.ID.init(rawValue: 22518040),
                                   pathwayId: Pathway.ID.init(rawValue: 2067),
                                   appointmentId: Appointment.ID.init(rawValue: 74994803)
    )!

    let photosStep = StepForm(
        store: Store(
        initialState: stepState,
        reducer: stepReducer,
        environment: makeJourneyEnv(makeTabBarEnv(appEnv))
        )
    )

    let photosNavigation = NavigationView.init(content: {
        photosStep
    }).navigationViewStyle(StackNavigationViewStyle())
    return photosNavigation
}
