import SwiftUI
import ComposableArchitecture
import Util
import Model

public protocol CompleteBtnState {
	var canProceed: Bool { get }
	var title: String { get }
}

public enum CompleteBtnAction {
	case onTap
}

public struct CompleteButton<State>: View where State: Equatable & CompleteBtnState {
    public init(store: Store<State, CompleteBtnAction>) {
        self.store = store
    }
    
	let store: Store<State, CompleteBtnAction>
	public var body: some View {
		WithViewStore(store) { viewStore in
			PrimaryButton(Texts.complete,
						  isDisabled: !viewStore.canProceed) {
				viewStore.send(.onTap)
			}
		}
	}
}

extension HTMLForm: CompleteBtnState {
	public var title: String {
		name
	}
}

extension ClientBuilder: CompleteBtnState {
	public var canProceed: Bool {
		return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
	}

	public var title: String {
		"Patient Details"
	}
}
