import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public let addClientOptionalReducer: Reducer<AddClientState?, AddClientAction, ClientsEnvironment> = .combine(
	addClientReducer.optional.pullback(
		state: \.self,
		action: /AddClientAction.self,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .onBackFromAddClient, .onResponseSave:
			state = nil
		default: break
		}
		return .none
	}
)

public let addClientReducer: Reducer<AddClientState, AddClientAction, ClientsEnvironment> = .combine(
	.init { state, action, env in
		return .none
	},
	addPhotoReducer.pullback(
		state: \.addPhoto,
		action: /AddClientAction.addPhoto,
		environment: { $0 }
	),
	patientDetailsReducer.pullback(
		state: \.patDetails,
		action: /AddClientAction.patDetails,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .saveClient:
			return env.apiClient.post(patDetails: state.patDetails)
				.catchToEffect()
				.map(AddClientAction.onResponseSave)
				.eraseToEffect()
		case .patDetails, .addPhoto, .onBackFromAddClient, .onResponseSave:
			break
		}
		return .none
	}
)

public struct AddClientState: Equatable {
	init (patDetails: PatientDetails) {
		self.patDetails = patDetails
		self.newPhoto = nil
		self.selectCameraTypeActionSheet = nil
		self.cameraType = nil
	}
	var patDetails: PatientDetails
	var newPhoto: UIImage?
	var selectCameraTypeActionSheet: ActionSheetState<AddPhotoAction>?
	var cameraType: UIImagePickerController.SourceType?

	var addPhoto: AddPhotoState {
		get {
			AddPhotoState(imageUrl: patDetails.imageUrl,
										newPhoto: self.newPhoto,
										selectCameraTypeActionSheet: self.selectCameraTypeActionSheet,
										cameraType: self.cameraType
			)
		}
		set {
			self.patDetails.imageUrl = newValue.imageUrl
			self.newPhoto = newValue.newPhoto
			self.selectCameraTypeActionSheet = newValue.selectCameraTypeActionSheet
			self.cameraType = newValue.cameraType
		}
	}
}

public enum AddClientAction: Equatable {
	case patDetails(PatientDetailsAction)
	case addPhoto(AddPhotoAction)
	case onBackFromAddClient
	case saveClient
	case onResponseSave(Result<PatientDetails, RequestError>)
}

struct AddClient: View {
	let store: Store<AddClientState, AddClientAction>
	var body: some View {
		WithViewStore(self.store) { viewStore in
			VStack {
				AddPhotoParent(store: self.store.scope(
					state: { $0.addPhoto }, action: { .addPhoto($0) }
				)).padding()
				PatientDetailsForm(store: self.store.scope(
					state: { $0.patDetails }, action: { .patDetails($0) })
				).padding()
			}.navigationBarItems(
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

//extension PatientDetails {
//	static let empty: PatientDetails(
//	salutation: "",
//	firstName: "",
//	lastName: "",
//	dob: "",
//	phone: "",
//	cellPhone: "",
//	email: "",
//	addressLine1: "",
//	addressLine2: "",
//	postCode: "",
//	city: "",
//	county: "",
//	country: "",
//	howDidYouHear: "",
//	emailComm: false,
//	smsComm: false,
//	phoneComm: false,
//	postComm: false
//	)
//}
