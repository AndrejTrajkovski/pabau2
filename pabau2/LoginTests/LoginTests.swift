import XCTest
@testable import Login
import ComposableArchitecture
import ComposableArchitectureTestSupport
import SnapshotTesting
import SwiftUI
import Model

class LoginTests: XCTestCase {

	override func setUp() {

	}

	func testLoginValidation() {
		let initialState = WalkthroughContainerState(navigation: Navigation.login([.signInScreen]), loggedInUser: nil, loginViewState: LoginViewState())
		let reducer = loginViewReducer
		let env = LoginEnvironment(
			apiClient: MockAPIClient(delay: 0),
			userDefaults: UserDefaults.standard
		)
		assert(initialValue: initialState,
					 reducer: reducer,
					 environment: env,
					 steps:
			Step(.send, LoginViewAction.login(.loginTapped(email: "asd@asd.com", password: "asd"))) { (state: inout WalkthroughContainerState) in
				state.loginViewState.loginLS = .loading
			},
			Step(.receive, LoginViewAction.login(.gotResponse(.success(User(id: 1, name: "Andrej"))))) { (state: inout WalkthroughContainerState) in
				state.loginViewState.loginLS = .gotSuccess(User(id: 1, name: "Andrej"))
				state.loggedInUser = User(id: 1, name: "Andrej")
				state.navigation = .tabBar(.journey)
			}
		)
//		assert(
//			initialValue: ,
//			reducer: loginViewReducer,
//			environment: LoginEnvironment(
//				apiClient: MockAPIClient(),
//				userDefaults: UserDefaults.standard
//			),
//			steps: Step(.receive, .login(.loginTapped) { state in
//					state.loginViewState.loginLS = .pending
//				})
//			)
//		)
	}

	override func tearDown() {

	}
}
