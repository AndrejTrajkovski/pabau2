import SwiftUI
import ComposableArchitecture
import Util
import Model
import PencilKit
import Overture
import ASCollectionView

public struct PhotosState: Equatable, Identifiable {
    public init(id: Step.ID, pathwayId: Pathway.ID, imageModels: [ImageModel], clientId: Client.ID) {
        self.id = id
        self.pathwayId = pathwayId
        self.clientId = clientId
        //TODO get image models for appointment and add to photos array
    }

    public let pathwayId: Pathway.ID
    public let id: Step.ID
    public var photos: IdentifiedArray<PhotoVariantId, PhotoViewModel> = []
    public var selectedIds: [PhotoVariantId] = []
    public var editPhotos: EditPhotosState?
    public let clientId: Client.ID
    //    public var stepStatus: StepStatus
    
    var selectPhotos: SelectPhotosState {
        get { SelectPhotosState(photos: photos, selectedIds: selectedIds) }
        set { self.selectedIds = newValue.selectedIds}
    }
    public func selectedPhotos() -> IdentifiedArray<PhotoVariantId, PhotoViewModel> {
        photos.filter { selectedIds.contains($0.id) }
    }
}

public let photosFormReducer: Reducer<PhotosState, PhotosFormAction, FormEnvironment> =
    .combine(
        editPhotosReducer.optional().pullback(
            state: \PhotosState.editPhotos,
            action: /PhotosFormAction.editPhoto,
            environment: { $0 }),
        Reducer.init { state, action, _ in
            switch action {
            case .didSelectEditPhotos:
                let selPhotos = state.photos.filter { state.selectedIds.contains($0.id) }
                let pidsid = PathwayIdStepId(step_id: state.id, path_taken_id: state.pathwayId)
                state.editPhotos = EditPhotosState(selPhotos, pathwayIdStepId: pidsid, clientId: state.clientId)
            case .editPhoto(.goBack):
                if state.photos.map(\.savePhotoState).allSatisfy({ !$0.isLoading }) {
                    state.editPhotos = nil
                }
            case .didTouchBackOnEditPhotos, .editPhoto(.abortUpload):
                state.editPhotos = nil
            case .editPhoto(.saveResponse(let idx, let result)):
                let savingStates = state.photos.map(\.savePhotoState)
                let allUploadsAreFinished = savingStates.allSatisfy { !$0.isLoading }
                if allUploadsAreFinished {
                    guard var editPhotos = state.editPhotos else {
                        return .none
                    }
                    let id = editPhotos.photos[idx].id
                    editPhotos.photos.filter { $0.savePhotoState == .gotSuccess}.forEach {
                        state.photos[id: $0.id] = $0
                    }
                    editPhotos.photos = editPhotos.photos.filter { $0.savePhotoState != .gotSuccess }
                    if editPhotos.editingPhotoId == id {
                        if editPhotos.editingPhotoId == nil {
                            state.editPhotos = nil
                        } else {
                            editPhotos.editingPhotoId = editPhotos.photos.last?.id
                            state.editPhotos = editPhotos
                        }
                    }
                }
//            case .editPhoto(.save):
//                guard let editedPhotos = state.editPhotos?.photos else { break }
//                state.selectedIds.forEach {
//                    state.photos[id: $0] = editedPhotos[id: $0]
//                }
//                state.editPhotos = nil
//                state.selectedIds.removeAll()
            case .editPhoto, .selectPhotos: break
            }
            return .none
        },
        selectPhotosReducer.pullback(
            state: \PhotosState.selectPhotos,
            action: /PhotosFormAction.selectPhotos,
            environment: { $0 })
    ).debug()

public enum PhotosFormAction: Equatable {
    case selectPhotos(SelectPhotosAction)
    case didSelectEditPhotos
    case didTouchBackOnEditPhotos
    case editPhoto(EditPhotoAction)
}

public struct PhotosForm: View {
    
    let store: Store<PhotosState, PhotosFormAction>
    @ObservedObject var viewStore: ViewStore<State, PhotosFormAction>
    
    public init(store: Store<PhotosState, PhotosFormAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: State.init(state:)))
    }
    
    struct State: Equatable {
        let isEditPhotosActive: Bool
        init (state: PhotosState) {
            self.isEditPhotosActive = state.editPhotos != nil
        }
    }
    
    public var body: some View {
        VStack {
            SelectPhotos(store: self.store.scope(
                            state: { $0.selectPhotos },
                            action: { .selectPhotos($0) }))
            NavigationLink.emptyHidden(
                viewStore.state.isEditPhotosActive,
                editPhotos
            )
        }
    }
    
    var editPhotos: some View {
        IfLetStore(self.store.scope(
                    state: { $0.editPhotos }, action: { .editPhoto($0) }),
                   then: {
                    EditPhotos(store: $0)
//                        .navigationBarItems(leading:
//                                                MyBackButton(text: Texts.back, action: { viewStore.send(.didTouchBackOnEditPhotos)}
//                                                ), trailing:
//                                                    Button(action: { viewStore.send(.saveEdited) },
//                                                           label: { Text(Texts.save) })
//                        ).navigationBarBackButtonHidden(true)
                   }
        )
    }
}

extension IdentifiedArray where Element == PhotoViewModel, ID == PhotoVariantId {
    static func wrap (_ savedPhotos: [[SavedPhoto.ID: SavedPhoto]]) -> Self {
        let res = savedPhotos
            .compactMap(Dictionary<PhotoVariantId, PhotoViewModel>.wrap)
            .compactMap(\.values.first)
        return IdentifiedArray(uniqueElements: res)
    }
}

extension Dictionary where Key == PhotoVariantId, Value == PhotoViewModel {
    static func wrap(_ savedPhotoDict: [SavedPhoto.ID: SavedPhoto]) -> Self? {
        guard savedPhotoDict.count == 1 else { return nil }
        return [PhotoVariantId.saved(savedPhotoDict.keys.first!):
                    PhotoViewModel.init(savedPhotoDict.values.first!) ]
    }
}
