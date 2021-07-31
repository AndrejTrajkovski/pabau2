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
        case form
        case loading
        case saving
        case skipping
        case retry
    }
    
    var body: some View {
        switch viewStore.state {
        case .form:
            stepFormView()
        case .loading:
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
