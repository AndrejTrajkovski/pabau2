import Combine
import ComposableArchitecture
import SwiftUI

struct AppState {
	var isWalkthroughFinished: Bool
  struct User {
    let id: Int
    let name: String
  }
}

enum AppAction {
	case walkthrough(WalkthroughAction)
	var walkthrough: WalkthroughAction? {
		get {
			guard case let .walkthrough(value) = self else { return nil }
			return value
		}
		set {
			guard case .walkthrough = self, let newValue = newValue else { return }
			self = .walkthrough(newValue)
		}
	}
}

extension AppState {
  var walktrough: WalkthroughState {
    get {
			WalkthroughState(isFinished: self.isWalkthroughFinished)
    }
    set {
			return self.isWalkthroughFinished = newValue.isFinished
    }
  }
}

let appReducer = pullback(walkthroughReducer, value: \AppState.walktrough, action: \AppAction.walkthrough)

struct ContentView: View {
  @ObservedObject var store: Store<AppState, AppAction>

  var body: some View {
		NavigationView {
			WalkthroughContainerView(store:
				self.store.view(
					value: { $0.walktrough },
					action: { .walkthrough($0)}
				)
			)
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
