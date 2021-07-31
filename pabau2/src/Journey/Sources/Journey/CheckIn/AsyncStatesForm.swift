import SwiftUI
import Util
import ToastAlert
import Model
import ComposableArchitecture
import SharedComponents

struct StepFormContainer: View {
    
    let store: Store<StepState, StepAction>
    @ObservedObject var viewStore: ViewStore<AsyncState, StepAction>
    
    @ViewBuilder let stepFormView: () -> StepForm
    
    enum AsyncState: Equatable {
        case initial
        case form
        case getting
        case saving
        case skipping
        case retry
        
        init(state: StepState) {
            switch state.loadingState {
            case .initial:
                self = .initial
            case .gotSuccess:
                switch state.savingState {
                case .loading:
                    self = .saving
                case .initial, .gotSuccess, .gotError:
                    self = .form //error handled with toast message
                }
                switch state.skipStepState {
                case .loading:
                    self = .saving
                case .initial, .gotSuccess, .gotError:
                    self = .form //error handled with toast message
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
        case .form:
            stepFormView()
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
        }
    }
}
