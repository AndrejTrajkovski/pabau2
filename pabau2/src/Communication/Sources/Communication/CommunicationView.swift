import SwiftUI
import ComposableArchitecture
import Util
import Model

public typealias CommunicationEnvironment = (
    loginAPI: LoginAPI,
    appointmentsAPI: AppointmentsAPI,
    clientsAPI: ClientsAPI,
	formAPI: FormAPI,
    userDefaults: UserDefaultsConfig
)

public let communicationReducer = Reducer<CommunicationState, CommunicationAction, CommunicationEnvironment> { _, action, _ in
    switch action {
    case .liveChat:
        return .none

    case .helpGuides:
        return .none

    case .carousel:
        return .none
    }
}

public struct CommunicationState: Equatable {
    public init () {}
}

public enum CommunicationAction {
    case liveChat, helpGuides, carousel
}

public struct CommunicationView: View {
    let store: Store<CommunicationState, CommunicationAction>
    @ObservedObject var viewStore: ViewStore<CommunicationState, CommunicationAction>

    public init (store: Store<CommunicationState, CommunicationAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            PrimaryButton(Texts.liveChat) {
                self.viewStore.send(.liveChat)
            }.frame(minWidth: 304, maxWidth: 495)

            PrimaryButton(Texts.helpGuides) {
                self.viewStore.send(.helpGuides)
            }.frame(minWidth: 304, maxWidth: 495)

            PrimaryButton("Carousel") {
                self.viewStore.send(.carousel)
            }.frame(minWidth: 304, maxWidth: 495)
        }
    }
}
