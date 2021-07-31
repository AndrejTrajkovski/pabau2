import SwiftUI
import Util
import ToastAlert
import Model
import ComposableArchitecture
import SharedComponents
import AlertToast

struct StepFormContainer: View {
    
    let store: Store<StepState, StepAction>
    @ObservedObject var viewStore: ViewStore<AsyncState, StepAction>
    
    init(store: Store<StepState, StepAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: AsyncState.init(state:)))
    }
    
    enum AsyncState: Equatable {
        case initial
        case form(errorToastMessage: String?)
        case getting
        case saving
        case skipping
        case retry
        
        init(state: StepState) {
            switch state.loadingState {
            case .initial:
                self = .initial
            case .gotSuccess:
                switch (state.savingState, state.skipStepState) {
                case (.loading, .loading):
                    fatalError("view logic should not allow")
                case (.loading, _):
                    self = .saving
                case (_, .loading):
                    self = .skipping
                case (_, .gotError):
                    self = .form(errorToastMessage: "Failed to skip step")
                case (.gotError, _):
                    self = .form(errorToastMessage: "Failed to save step")
                case (.initial, .initial),
                     (.gotSuccess, .initial),
                     (.initial, .gotSuccess),
                     (.gotSuccess, .gotSuccess):
                    self = .form(errorToastMessage: nil)
                }
            case .loading:
                self = .getting
            case .gotError:
                self = .retry
            }
        }
    }
    
    var body: some View {
        switch viewStore.state {
        case .form(let toastMessage):
            StepForm(store: store)
                .toast(isPresenting: .constant(toastMessage != nil),
                       duration: 1,
                       tapToDismiss: false,
                       alert: { AlertToast(displayMode: .alert,
                                         type: .error(.red),
                                         title: toastMessage ?? "",
                                         subTitle: nil,
                                         custom: nil) }
                )
        case .getting:
            LoadingView.init(title: "Loading", bindingIsShowing: .constant(true), content: { Spacer() })
        case .saving:
            LoadingView.init(title: "Saving", bindingIsShowing: .constant(true), content: { Spacer() })
        case .skipping:
            LoadingView.init(title: "Skipping", bindingIsShowing: .constant(true), content: { Spacer() })
        case .retry:
            VStack {
                RawErrorView(description: "Failed to load form.")
                Button("Retry", action: { viewStore.send(.retryGetForm) })
                Spacer()
            }
        case .initial:
            EmptyView()
        }
    }
}
