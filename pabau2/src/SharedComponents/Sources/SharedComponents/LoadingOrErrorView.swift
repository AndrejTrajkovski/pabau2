import SwiftUI
import ComposableArchitecture
import Util
import Model

public struct IfLetErrorView: View {
	
	let store: Store<LoadingState, ErrorViewAction>

	public init(store: Store<LoadingState, ErrorViewAction>) {
		self.store = store
	}
	
	public var body: some View {
		IfLetStore(store.scope(state: { state in
            if case .gotError(let error) = state {
                return error as? RequestError
            } else {
                return nil
            }
		}),
			then: ErrorRetry.init(store:)
		)
	}
}

public enum ErrorViewAction {
	case retry
}

public struct ErrorRetry: View {
	
	public init(store: Store<RequestError, ErrorViewAction>) {
		self.store = store
	}
	
	let store: Store<RequestError, ErrorViewAction>
	public var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				PlainError(store: store.actionless)
				Button("Retry", action: { viewStore.send(.retry) })
			}
		}
	}
}

struct PlainError: View {
	let store: Store<RequestError, Never>
	var body: some View {
		WithViewStore(store) { viewStore in
			Text(viewStore.state.userMessage).foregroundColor(.red)
		}
	}
}

struct LoadingOrErrorView: View {
	
	let store: Store<LoadingState, ErrorViewAction>
	
	var body: some View {
		WithViewStore(store) { viewStore in
			ZStack {
				if case .gotError(let error) = viewStore.state {
					VStack {
						ErrorView(error: error)
						Button("Retry", action: { viewStore.send(.retry) })
						Spacer()
					}
				} else {
					LoadingSpinner(title: "Loading Pathway Data...")
				}
			}
		}
	}
}
