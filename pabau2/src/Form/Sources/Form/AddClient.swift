import SwiftUI
import ComposableArchitecture
import Model
import Util

public let addClientReducer: Reducer<AddClientState, AddClientAction, FormEnvironment> = .combine(
	addPhotoReducer.pullback(
		state: \.addPhoto,
		action: /AddClientAction.addPhoto,
		environment: { $0 }
	),
	patientDetailsReducer.pullback(
		state: \.clientBuilder,
		action: /AddClientAction.clientBuilder,
		environment: { $0 }
	)
)

public struct AddClientState: Equatable {
	public init (clientBuilder: ClientBuilder) {
		self.clientBuilder = clientBuilder
		self.newPhoto = nil
		self.selectCameraTypeActionSheet = nil
		self.cameraType = nil
		self.photoUploading = .initial
		self.formSaving = .initial
	}
	public var clientBuilder: ClientBuilder
	public var newPhoto: UIImage?
	public var selectCameraTypeActionSheet: ActionSheetState<AddPhotoAction>?
	public var cameraType: UIImagePickerController.SourceType?
	public var saveFailureAlert: AlertState<AddClientAction>?
	public var photoUploading: LoadingState
	public var formSaving: LoadingState

	var addPhoto: AddPhotoState {
		get {
			AddPhotoState(clientBuilder: clientBuilder,
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
	case clientBuilder(PatientDetailsAction)
	case addPhoto(AddPhotoAction)
	case onResponseSave(Result<Client.ID, RequestError>)
	case saveAlertCanceled
}

public struct AddClient: View {
	
	public init(store: Store<AddClientState, AddClientAction>) {
		self.store = store
	}
	
	let store: Store<AddClientState, AddClientAction>
	
	public var body: some View {
		WithViewStore(self.store) { viewStore in
			VStack {
				AddPhotoParent(store: self.store.scope(
					state: { $0.addPhoto }, action: { .addPhoto($0) }
				)).padding()
				PatientDetailsForm(store: self.store.scope(
									state: { $0.clientBuilder },
									action: { .clientBuilder($0) })
				).padding()
				.loadingView(.constant(viewStore.formSaving == .loading), "Saving...")
				.alert(store.scope(state: \.saveFailureAlert), dismiss: AddClientAction.saveAlertCanceled)
			}
		}
	}
}
