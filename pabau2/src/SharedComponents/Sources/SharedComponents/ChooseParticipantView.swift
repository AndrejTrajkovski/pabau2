import SwiftUI
import ComposableArchitecture
import Util
import Model

public struct ChooseParticipantState: Equatable {
    public var participantSchema: ParticipantSchema?
    public var isChooseParticipantActive: Bool
    public var participants: IdentifiedArrayOf<Participant> = []
    public var filteredParticipants: IdentifiedArrayOf<Participant> = []
    public var chosenParticipants: [Participant] = []
    public var searchText: String = "" {
        didSet {
            isSearching = !searchText.isEmpty
        }
    }
    public var isSearching = false

    public init(isChooseParticipantActive: Bool) {
        self.isChooseParticipantActive = isChooseParticipantActive
    }
}

public enum ChooseParticipantAction: Equatable {
    case onAppear
    case gotParticipantsResponse(Result<[Participant], RequestError>)
    case didSelectParticipant(Participant)
    case onSearch(String)
    case didTapBackBtn
}

public struct ChooseParticipantView: View {
    let store: Store<ChooseParticipantState, ChooseParticipantAction>
    @ObservedObject var viewStore: ViewStore<ChooseParticipantState, ChooseParticipantAction>
    
    public init(store: Store<ChooseParticipantState, ChooseParticipantAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.clear
    }

    public var body: some View {
        VStack {
            SearchView(
                placeholder: "Search",
                text: viewStore.binding(
                    get: \.searchText,
                    send: ChooseParticipantAction.onSearch)
            )
            List {
                ForEach(self.viewStore.state.filteredParticipants, id: \.id) { participant in
                    TextAndCheckMark(
                        participant.fullName ?? "",
                         self.viewStore.state.chosenParticipants.contains(where: {$0.id == participant.id})
                    ).onTapGesture {
                        self.viewStore.send(.didSelectParticipant(participant))
                    }
                }
            }
        }
        .onAppear {
            self.viewStore.send(.onAppear)
        }
        .padding()
        .navigationBarTitle("Participants")
        .customBackButton(action: { self.viewStore.send(.didTapBackBtn)})
    }
}
