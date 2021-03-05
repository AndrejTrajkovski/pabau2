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
		case .onBackFromAddClient:
			state = nil
		case .onResponseSave(let result):
			switch result {
			case .success:
				break
			case .failure(let error):
				state?.saveFailureAlert = AlertState(
					title: "Updating Contact Failed",
					message: error.description,
					dismissButton: .default("OK")
				)
			}
		default: break
		}
		return .none
	}
)

public let addClientReducer: Reducer<AddClientState, AddClientAction, ClientsEnvironment> = .combine(
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
			return env.apiClient.update(patDetails: state.patDetails)
				.catchToEffect()
				.receive(on: DispatchQueue.main)
				.map(AddClientAction.onResponseSave)
				.eraseToEffect()
		case .patDetails, .addPhoto, .onResponseSave:
			break
		case .onBackFromAddClient:
			return .cancel(id: UploadPhotoId())
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
		self.photoUploading = .initial
	}
	var patDetails: PatientDetails
	var newPhoto: UIImage?
	var selectCameraTypeActionSheet: ActionSheetState<AddPhotoAction>?
	var cameraType: UIImagePickerController.SourceType?
	var saveFailureAlert: AlertState<AddClientAction>?
	var photoUploading: LoadingState
	
	var addPhoto: AddPhotoState {
		get {
			AddPhotoState(patDetails: patDetails,
						  newPhoto: self.newPhoto,
						  selectCameraTypeActionSheet: self.selectCameraTypeActionSheet,
						  cameraType: self.cameraType,
						  photoUploading: photoUploading
			)
		}
		set {
			self.newPhoto = newValue.newPhoto
			self.selectCameraTypeActionSheet = newValue.selectCameraTypeActionSheet
			self.cameraType = newValue.cameraType
			self.photoUploading = newValue.photoUploading
		}
	}
}

public enum AddClientAction: Equatable {
	case patDetails(PatientDetailsAction)
	case addPhoto(AddPhotoAction)
	case onBackFromAddClient
	case saveClient
	case onResponseSave(Result<VoidAPIResponse, RequestError>)
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
