import SwiftUI
import Model
import ComposableArchitecture
import Util
import SharedComponents

let chooseParticipantReducer =
    Reducer<ChooseParticipantState, ChooseParticipantAction, AddAppointmentEnv> { state, action, env in
        switch action {
        case .onAppear:
            guard let participantSchema = state.participantSchema  else {
                break
            }
 
            state.searchText = ""
            return env.journeyAPI.getParticipants(
                participantSchema: participantSchema
            )
            .catchToEffect()
            .map(ChooseParticipantAction.gotParticipantsResponse)
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        case .onSearch(let text):
            state.searchText = text
            if state.searchText.isEmpty {
                state.filteredParticipants = state.participants
                break
            }

            state.filteredParticipants = state.participants.filter {$0.fullName?.lowercased().contains(text.lowercased()) == true}
        case .gotParticipantsResponse(let result):
            switch result {
            case .success(let participants):
                state.participants = .init(participants)
                state.filteredParticipants = state.participants
            case .failure:
                break
            }
        case .didSelectParticipant(let participant):
            state.chosenParticipant = participant
            state.isChooseParticipantActive = false
        case .didTapBackBtn:
            state.isChooseParticipantActive = false
        }
        return .none
    }
