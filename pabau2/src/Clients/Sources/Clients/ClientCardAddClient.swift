import SwiftUI
import ComposableArchitecture
import Model
import Util
import Form

public let addClientOptionalReducer: Reducer<AddClientState?, ClientCardAddClientAction, ClientsEnvironment> = .combine(
	addClientReducer.optional().pullback(
		state: \.self,
		action: /ClientCardAddClientAction.addClient,
		environment: {
			FormEnvironment(
				formAPI: $0.formAPI,
				userDefaults: $0.userDefaults
			)
		}
	),
	.init { state, action, env in
		switch action {
		case .onBackFromAddClient:
			state = nil
		case .addClient(.onResponseSave(let result)):
			switch result {
			case .success:
				break
			case .failure(let error):
				state?.formSaving = .gotError(error)
				state?.saveFailureAlert = AlertState(
					title: TextState("Updating Contact Failed"),
					message: TextState(error.description),
					dismissButton: .default(TextState("OK"))
				)
			}
		default: break
		}
		return .none
	}
)

//public let clientCardAddClientReducer: Reducer<AddClientState, ClientCardAddClientAction, ClientsEnvironment> = .combine(
//.init { state, action, env in
//	switch action {
//	case .saveClient:
//		state.formSaving = .loading
//		return env.apiClient.update(clientBuilder: state.clientBuilder)
//			.catchToEffect()
//			.receive(on: DispatchQueue.main)
//			.map(AddClientAction.onResponseSave)
//			.eraseToEffect()
//	case .saveAlertCanceled:
//		state.saveFailureAlert = nil
//	case .clientBuilder, .addPhoto, .onResponseSave:
//		break
//	case .onBackFromAddClient:
//		return .cancel(id: UploadPhotoId())
//	}
//	return .none
//},
// addClientReducer.pullback
//)


public enum ClientCardAddClientAction: Equatable {
	case addClient(AddClientAction)
	case onBackFromAddClient
	case saveClient
}

struct ClientCardAddClient: View {
	let store: Store<AddClientState, ClientCardAddClientAction>
	
	var body: some View {
		WithViewStore(self.store) { viewStore in
			AddClient(store: store.scope(state: { $0 }, action: { .addClient($0) }))
				.navigationBarItems(
					leading:
						MyBackButton(text: Texts.back, action: {
							viewStore.send(.onBackFromAddClient)
						}), trailing:
							Button(action: { viewStore.send(.saveClient) },
								   label: { Text(Texts.save) }
							)
				).navigationBarBackButtonHidden(true)
		}
	}
}
