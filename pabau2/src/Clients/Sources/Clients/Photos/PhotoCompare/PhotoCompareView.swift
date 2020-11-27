import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public enum PhotoCompareAction: Equatable {
    case didSelectComparePhoto(PhotoCompareMode)
    case didChangeSelectedPhoto(PhotoVariantId)
    case didSelectShare
    case shareAction(PhotoShareAction)
}

public enum PhotoCompareMode: Equatable {
    case single
    case multiple
}

struct PhotoCompareState: Equatable {
    public init() { }
    
    public init(date: Date?, photos: [PhotoViewModel]) {
        self.date = date
        self.photos = photos
        selectedPhoto = self.photos.first
    }
    
    var photoCompareMode: PhotoCompareMode = .single
    var selectedPhoto: PhotoViewModel?
    var date: Date?
    var photos: [PhotoViewModel] = []
    
    var onShareSelected: Bool = false
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
    case .didSelectComparePhoto(let mode):
        state.photoCompareMode = mode
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
                    HStack {
                        PhotoDetailView(store: self.store)
                        PhotoDetailView(store: self.store)
                    }
                }
                
                Spacer()
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(viewStore.photos) { item in
                            Button(action: {
                                viewStore.send(.didChangeSelectedPhoto(item.id))
                            }) {
                                PhotoCell(photo: item)
                                    .frame(width: 90, height: 110)
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 110)
                
                if let selectedPhoto = viewStore.selectedPhoto {
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
                        viewStore.send(.didSelectComparePhoto(viewStore.state.photoCompareMode == .single ? .multiple : .single))
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
