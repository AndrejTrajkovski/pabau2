import SwiftUI
import ComposableArchitecture
import CasePaths
import Model
import Util
import Journey

public typealias TabBarEnvironment = (loginAPI: LoginAPI, journeyAPI: JourneyAPI, userDefaults: UserDefaults)

public struct TabBarState {
	public var navigation: Navigation
	public var journeyState: JourneyState
}

extension TabBarState {
	var settings: SettingsState {
		get { SettingsState(navigation: self.navigation)}
		set { self.navigation = newValue.navigation }
	}
	var journey: JourneyState {
		get {
			return self.journeyState
		}
		set {
			self.journeyState = newValue
		}
	}
}

public enum TabBarAction {
	case settings(SettingsAction)
	case journey(JourneyContainerAction)
}

struct PabauTabBar: View {
	let store: Store<TabBarState, TabBarAction>
	var body: some View {
		ZStack(alignment: .topTrailing) {
			TabView {
				JourneyNavigationView(self.store.view(value: { $0.journey },
																							action: { .journey($0)}))
					.tabItem {
						Image(systemName: "staroflife")
						Text("Journey")
				}
				Text("Calendar")
					.tabItem {
						Image(systemName: "calendar")
						Text("Calendar")
				}
				Settings(store:
					store.view(value: { $0.settings },
										 action: { .settings($0)}))
					.tabItem {
						Image(systemName: "gear")
						Text("Settings")
				}
			}
			EmployeesListStore(self.store.view(value: { $0.journey.employeesState } ,
																				 action: { .journey(.employees($0))}))
				.isHidden(!self.store.value.journey.employeesState.isShowingEmployees)
				.frame(width: self.store.value.journey.employeesState.isShowingEmployees ? 302 : 0)
		}
	}
}

public struct SettingsState {
	var navigation: Navigation
}

public enum SettingsAction {
	case logoutTapped
}

public let tabBarReducer = combine(
	pullback(settingsReducer,
					 value: \TabBarState.settings,
					 action: /TabBarAction.settings,
					 environment: { $0 }),
	pullback(journeyContainerReducer,
					 value: \TabBarState.journey,
					 action: /TabBarAction.journey,
					 environment: {
						return JourneyEnvironemnt(
							apiClient: $0.journeyAPI,
							userDefaults: $0.userDefaults)
	})
)

public func settingsReducer(state: inout SettingsState, action: SettingsAction, environment: TabBarEnvironment) -> [Effect<SettingsAction>] {
	switch action {
	case .logoutTapped:
		state.navigation = .login([.signInScreen])
		return []
	}
}

public struct Settings: View {
	@ObservedObject var store: Store<SettingsState, SettingsAction>
	public var body: some View {
		VStack {
			BigButton(text: "Logout") {
				self.store.send(.logoutTapped)
			}
		}
	}
}

extension View {

    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        modifier(HiddenModifier(isHidden: hidden, remove: remove))
    }
}


/// Creates a view modifier to show and hide a view.
///
/// Variables can be used in place so that the content can be changed dynamically.
fileprivate struct HiddenModifier: ViewModifier {

    private let isHidden: Bool
    private let remove: Bool

    init(isHidden: Bool, remove: Bool = false) {
        self.isHidden = isHidden
        self.remove = remove
    }

    func body(content: Content) -> some View {
        Group {
            if isHidden {
                if remove {
                    EmptyView()
                } else {
                    content.hidden()
                }
            } else {
                content
            }
        }
    }
}
