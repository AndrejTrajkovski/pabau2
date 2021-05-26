import SwiftUI
import Model
import Util
import ComposableArchitecture
import Overture
import Combine
import CoreDataModel
import SharedComponents

public typealias ChoosePathwayEnvironment = (
    formAPI: FormAPI,
    journeyAPI: JourneyAPI,
    clientsAPI: ClientsAPI,
    userDefaults: UserDefaultsConfig,
	repository: Repository
)

public enum ChoosePathwayContainerAction: Equatable {
    case rows(id: PathwayTemplate.ID, action: PathwayTemplateRowAction)
    case matchResponse(Result<Pathway, RequestError>)
    case gotPathwayTemplates(Result<IdentifiedArrayOf<PathwayTemplate>, RequestError>)
    case dismissPathwayErrorAlert
}

public let choosePathwayContainerReducer: Reducer<ChoosePathwayState, ChoosePathwayContainerAction, ChoosePathwayEnvironment> =
    .combine(
        Reducer.init { state, action, env in
            switch action {
                
            case .gotPathwayTemplates(let pathwayTemplates):
                print(pathwayTemplates)
                state.pathwayTemplates.update(pathwayTemplates)
                
            case .rows(let id, _):
                guard case .loaded(let pathways) = state.pathwayTemplates else { return .none }
                state.selectedPathway = pathways[id: id]
                return env.journeyAPI.match(appointment: state.selectedAppointment,
                                            pathwayTemplateId: id)
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map { ChoosePathwayContainerAction.matchResponse($0) }
                    .eraseToEffect()
                
            case .matchResponse(.success):
                break //handled in parent reducer
            
            case .matchResponse(.failure(let error)):
                state.matchPathwayErrorAlert = AlertState(
                    title: TextState("Error Choosing Pathway"),
                    message: TextState(error.description),
                    dismissButton: .default(TextState("OK"), send: .dismissPathwayErrorAlert)
                )
                
            case .dismissPathwayErrorAlert:
                state.matchPathwayErrorAlert = nil
            }
            
            return .none
        }
)

public struct ChoosePathwayState: Equatable {
    
    public let selectedAppointment: Appointment
    public var selectedPathway: PathwayTemplate?
    var pathwayTemplates: LoadingState2<IdentifiedArrayOf<PathwayTemplate>> = .loading
    var matchPathwayErrorAlert: AlertState<ChoosePathwayContainerAction>?
    
    public init(selectedAppointment: Appointment) {
        self.selectedAppointment = selectedAppointment
    }
}

public struct ChoosePathway: View {
    let store: Store<ChoosePathwayState, ChoosePathwayContainerAction>
    @ObservedObject var viewStore: ViewStore<State, ChoosePathwayContainerAction>
    struct State: Equatable {
        let isChooseConsentShown: Bool
        let appointment: Appointment?
        init(state: ChoosePathwayState) {
            self.isChooseConsentShown = state.selectedPathway != nil
            self.appointment = state.selectedAppointment
            UITableView.appearance().separatorStyle = .none
        }
    }

    public init(store: Store<ChoosePathwayState, ChoosePathwayContainerAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store
            .scope(state: State.init(state:),
                         action: { $0 }))
    }
    
    public var body: some View {
        LoadingStore(store.scope(state: { $0.pathwayTemplates }, action: { $0 }),
                     then: { (tmplts: Store<IdentifiedArrayOf<PathwayTemplate>,
                                            ChoosePathwayContainerAction>) in
                        choosePathwayList(tmplts)
                     }
        )
        .alert(store.scope(state: \.matchPathwayErrorAlert),
               dismiss: ChoosePathwayContainerAction.dismissPathwayErrorAlert)
        .journeyBase(self.viewStore.state.appointment, .long)
    }

    fileprivate func choosePathwayList(_ tmplts: Store<IdentifiedArrayOf<PathwayTemplate>, ChoosePathwayContainerAction>) -> some View {
        return ScrollView {
            LazyVStack {
                ForEachStore(tmplts.scope(state: { $0 },
                                          action: { .rows(id: $0, action: $1) }),
                             content: PathwayTemplateRow.init(store:))
            }
        }
    }
}

public enum PathwayTemplateRowAction {
    case select
}

struct PathwayTemplateRow: View {
    let store: Store<PathwayTemplate, PathwayTemplateRowAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(viewStore.title).font(.semibold20).foregroundColor(.black42)
                    Spacer()
                    Image(systemName: "list.bullet").foregroundColor(.blue2)
                    Text(String("\(viewStore.steps.count)")).font(.semibold17)
                }
                Divider()
//                SecondaryButton(viewStore.title) {
//                    viewStore.send(.select)
//                }
            }.padding([.leading, .trailing])
            .onTapGesture {
                viewStore.send(.select)
            }
        }.frame(height: 44)
    }
}
