import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public enum PhotoCompareAction: Equatable {
    case didChangeSelectedPhoto(PhotoVariantId)
    case didSelectShare
    case shareAction(PhotoShareSelectAction)
    case onBackCompare
    case sideBySideAction(PhotoSideBySideAction)
}

public enum PhotoCompareMode: Equatable {
    case single
    case multiple
}

struct PhotoCompareState: Equatable {
    public init(photos: [PhotoViewModel], selectedId: PhotoVariantId?) {
        self.photos = photos
        self.selectedId = selectedId
        
        selectedPhoto = self.photos.filter { $0.basePhoto.id == selectedId }.first
        if let selected = selectedPhoto {
            photoSideBySideState = PhotoSideBySideState(leftState: PhotoDetailState(photo: selected, changes: MagnificationZoom()),
                                                    rightState: PhotoDetailState(photo: selected, changes: MagnificationZoom()))
        }
        
        if let latestPhoto = latestPhotoTaken {
            photoSideBySideState.rightState.photo = latestPhoto
        }
    }
    
    var selectedId: PhotoVariantId?
    var selectedPhoto: PhotoViewModel?
    var latestPhotoTaken: PhotoViewModel? {
        photos.sorted{ $0.basePhoto.date > $1.basePhoto.date }.first
    }
    
    var photoCompareMode: PhotoCompareMode = .single
    var photos: [PhotoViewModel] = []
    
    var onBackCompare: Bool = false
    var onShareSelected: Bool = false
    
    var iconImageNavigationCompareMode: String {
        get {
            photoCompareMode == .single ? "ico-nav-compare" : "ico-nav-single"
        }
    }
    
    var shareSelectState: PhotoShareSelectState = PhotoShareSelectState()
    var photoSideBySideState: PhotoSideBySideState!
    
}

var photoCompareReducer = Reducer.combine(
    photoShareSelectViewReducer.pullback(
        state: \PhotoCompareState.shareSelectState,
        action: /PhotoCompareAction.shareAction,
        environment: { $0 }
    ),
    photoSideBySideReducer.pullback(
        state: \PhotoCompareState.photoSideBySideState,
        action: /PhotoCompareAction.sideBySideAction,
        environment: { $0 }
    ),
    Reducer<PhotoCompareState, PhotoCompareAction, ClientsEnvironment> { state, action, environment in
        switch action {
        case .didChangeSelectedPhoto(let photoId):
            if let photo = state.photos.filter { $0.id == photoId}.first {
                state.selectedPhoto = photo
                state.photoSideBySideState.activeSide.photo = photo
            }
        
        case .didSelectShare:
            if let selectedPhoto = state.selectedPhoto {
                state.shareSelectState = PhotoShareSelectState(photo: state.photoSideBySideState.leftState.photo,
                                                               comparedPhoto: state.photoSideBySideState.rightState.photo)
                state.onShareSelected = true
            }
        case .shareAction(.backButton):
            state.onShareSelected = false
        default:
            break
        }
        return .none
})

struct PhotoCompareView: View {
    let store: Store<PhotoCompareState, PhotoCompareAction>
    
    var body: some View {
        print("PhotoCompareView")
        return WithViewStore(self.store) { viewStore in
            VStack {                
                PhotoSideBySideView(store: store.scope(
                                        state: { $0.photoSideBySideState },
                                        action: { PhotoCompareAction.sideBySideAction($0)}
                                    )
                )
                
                Spacer()
                PhotosListTimelineView(store: self.store)
                
                if let _ = viewStore.selectedPhoto {
                    NavigationLink.emptyHidden(viewStore.onShareSelected,
                                               PhotoShareSelectView(store: self.store.scope(state: { $0.shareSelectState },
                                                                                      action: { PhotoCompareAction.shareAction($0) })
                                               ))
                    
                }
            }
            .navigationBarTitle("Progress Gallery")
            .navigationBarItems(
                leading: HStack {
                    MyBackButton(text: Texts.back) {
                        viewStore.send(.onBackCompare)
                    }
                },
                trailing: HStack {
                    Button(action: {
                        viewStore.send(.sideBySideAction(.changeDisplayMode))
                    }) {
                        Image(viewStore.iconImageNavigationCompareMode)
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
