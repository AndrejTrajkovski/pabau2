import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public enum PhotoCompareAction: Equatable {
    case changeComparePhotoMode
    case didChangeSelectedPhoto(PhotoVariantId)
    case didSelectShare
    case shareAction(PhotoShareAction)
    
    case onChangeDragOffset(CGSize)
    case onEndedDrag(CGSize)
    case onChangePinchMagnification(CGFloat)
    case onEndedMagnification(CGFloat)
    case onTappedToZoom
}

public enum PhotoCompareMode: Equatable {
    case single
    case multiple
}

struct PhotoCompareState: Equatable {
    public init(date: Date?, photos: [PhotoViewModel], selectedId: PhotoVariantId?) {
        self.date = date
        self.photos = photos
        
        if let selectedId = selectedId {
            selectedPhoto = self.photos.filter { $0.basePhoto.id == selectedId }.first
        } else {
            selectedPhoto = self.photos.first
        }
        
        photosCompares[0] = selectedPhoto
        photosCompares[1] = latestPhotoTaken
    }
    
    var photoCompareMode: PhotoCompareMode = .single
    var selectedPhoto: PhotoViewModel? {
        didSet {
            photosCompares[0] = selectedPhoto
        }
    }
    var latestPhotoTaken: PhotoViewModel? {
        photos.sorted{ $0.basePhoto.date > $1.basePhoto.date }.first
    }
    
    var photosCompares: Dictionary<Int, PhotoViewModel?> = [:]
    
    var date: Date?
    var photos: [PhotoViewModel] = []
    
    var onShareSelected: Bool = false
    
    var dragOffset: CGSize = .zero
    var position: CGSize = .zero
    var currentMagnification: CGFloat = 1
    var pinchMagnification: CGFloat = 1
    var isTappedToZoom: Bool = false
    
}

extension PhotoCompareState {
    var shareState: PhotoShareState {
        get {
            PhotoShareState(photo: selectedPhoto!)
        }
    }
}

var photoCompareReducer = Reducer<PhotoCompareState, PhotoCompareAction, ClientsEnvironment> { state, action, environment in
    switch action {
    case .didChangeSelectedPhoto(let photoId):
        if let photo = state.photos.filter { $0.id == photoId}.first {
            state.selectedPhoto = photo
        }
    case .didSelectShare:
        state.onShareSelected = true
    case .changeComparePhotoMode:
        state.photoCompareMode = state.photoCompareMode == .single ? .multiple : .single
    case .onChangeDragOffset(let size):
        state.dragOffset = size
    case .onEndedMagnification(let value):
        state.currentMagnification *= value
        state.pinchMagnification = 1
    case .onChangePinchMagnification(let value):
        state.pinchMagnification = value
    case .onEndedDrag(let value):
        state.position.width += value.width
        state.position.height += value.height
        state.dragOffset = .zero
    case .onTappedToZoom:
        state.isTappedToZoom.toggle()
        state.currentMagnification = state.isTappedToZoom ? 2 : 1
        if !state.isTappedToZoom {
            state.dragOffset = .zero
            state.position = .zero
        }
    default:
        break
    }
    return .none
}

struct PhotoCompareView: View {
    let store: Store<PhotoCompareState, PhotoCompareAction>
    
    var body: some View {
        print("PhotoCompareView")
        return WithViewStore(self.store) { viewStore in
            VStack {
                if viewStore.photoCompareMode == .single {
                    PhotoDetailView(store: self.store)
                } else {
                    HStack(spacing: 0) {
                        PhotoDetailView(store: self.store)
                        PhotoDetailView(store: self.store, positionCompare: 1)
                    }
                }
                
                Spacer()
                PhotosListTimelineView(store: self.store)
                                
                if let _ = viewStore.selectedPhoto {
                    NavigationLink.emptyHidden(viewStore.onShareSelected,
                                               PhotoShareView(store: self.store.scope(state: { $0.shareState },
                                                                                      action: { PhotoCompareAction.shareAction($0) })
                                               ))
                    
                }
            }
            .navigationBarTitle("Progress Gallery")
            .navigationBarItems(
                trailing: HStack {
                    Button(action: {
                        viewStore.send(.changeComparePhotoMode)
                    }) {
                        Image("ico-nav-compare")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Button("Share") {
                        viewStore.send(.didSelectShare)
                    }
                })
        }
    }
}
