import SwiftUI
import ComposableArchitecture
import Model

public struct HTMLFormCompleteBtn: View {
    
    public init(store: Store<HTMLForm, HTMLRowsAction>) {
        self.store = store
    }
    
    let store: Store<HTMLForm, HTMLRowsAction>
    
    struct State: Equatable {
        let canProceed: Bool
        init(state: HTMLForm) {
            self.canProceed = state.formStructure.allSatisfy {
                !$0._required || $0.cssClass.isFulfilled
            }
        }
    }
    
    public var body: some View {
        WithViewStore(store.scope(state: State.init(state:))) { viewStore in
            CompleteButton(canComplete: viewStore.canProceed,
                           onComplete: { viewStore.send(.complete)}
            )
        }
    }
}
