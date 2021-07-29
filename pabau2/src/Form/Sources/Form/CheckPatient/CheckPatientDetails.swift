import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

public let checkPatientDetailsReducer: Reducer<CheckPatientDetailsState, CheckPatientDetailsAction, FormEnvironment> = .init {
    state, action, env in
    switch action {
    case .complete:
        return .none //handled somehwere in parentReducers
    case .backToPatientMode:
        return .none //handled somehwere in parentReducers
    case .gotCompleteResponse:
        return .none //handled somehwere in parentReducers
    }
}

public enum CheckPatientDetailsAction: Equatable {
    case backToPatientMode
    case complete
    case gotCompleteResponse(Result<StepStatus, RequestError>)
}

public struct CheckPatientDetailsState: Equatable, Identifiable {
    public let id: Step.ID
    public var clientBuilder: ClientBuilder?
    public var patForms: [HTMLForm]
    
    public init (
        id: Step.Id,
        clientBuilder: ClientBuilder?,
        patForms: [HTMLForm]
    ) {
        self.id = id
        self.clientBuilder = clientBuilder
        self.patForms = patForms
    }
}


public struct CheckPatientDetails: View {
    
    let store: Store<CheckPatientDetailsState, CheckPatientDetailsAction>
    @ObservedObject var viewStore: ViewStore<CheckPatientDetailsState, CheckPatientDetailsAction>
    
    public init(store: Store<CheckPatientDetailsState, CheckPatientDetailsAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack {
                if let clientBuilder = viewStore.state.clientBuilder {
                    PatientDetailsForm(
                        store: Store.init(
                            initialState: clientBuilder,
                            reducer: Reducer.empty,
                            environment: { }
                        ),
                        isDisabled: true
                    )
                }
                ForEach(viewStore.patForms.indices, id: \.self ) { index in
                    HTMLFormView(
                        store: Store(
                            initialState: viewStore.patForms[index],
                            reducer: Reducer.empty,
                            environment: { }
                        ),
                        isCheckingDetails: true,
                        footer: { Optional<EmptyView>.none }
                    )
                }
            }.disabled(true)
        }
    }
}
