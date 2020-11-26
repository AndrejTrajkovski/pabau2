import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

public enum PhotoCompareAction {
    case didSelectComparePhoto
    case didChangeSelectedPhoto(String)
}

struct PhotoCompareState: Equatable {
    public init() { }
    
    public init(date: Date?, photos: [PhotoViewModel]) {
        self.date = date
        self.photos = photos
        selectedPhoto = self.photos.first
    }
    
    var selectedPhoto: PhotoViewModel?
    var date: Date?
    var photos: [PhotoViewModel] = []
}

public struct PhotosEnvironment {
    var apiClient: ClientsAPI
    var userDefaults: UserDefaultsConfig
}

var photoCompareReducer = Reducer<PhotoCompareState, CCPhotosAction, PhotosEnvironment> { state, action, environment in
    switch action {
    case .didTouchPhoto(let photoId):
        if let photo = state.photos.filter { $0.id == photoId}.first {
            state.selectedPhoto = photo
        }
    default:
        break
    }
    return .none
}


struct PhotoCompareView: View {
    
    let store: Store<PhotoCompareState, CCPhotosAction>
    
    var body: some View {
        print("PhotoCompareView")
        return WithViewStore(self.store) { viewStore in
            VStack {
                ZStack {
                    if let photo = viewStore.selectedPhoto {
                        PhotoCell(photo: photo)
                    }
  
                    VStack {
                        Spacer()
                        Text("Today")
                            .font(.regular32)
                            .foregroundColor(.white)
                        if let _ = viewStore.date {
                            Text("\(viewStore.date!)")
                                .foregroundColor(.white)
                        }
                        Spacer()
                            .frame(height: 20)
                    }
                }
                Spacer()
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(viewStore.photos) { item in
                            Button(action: {
                                
                            }) {
                                PhotoCell(photo: item)
                                    .frame(width: 90, height: 110)
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: 110)
            }
            .navigationBarTitle("Progress Gallery")
            .navigationBarItems(trailing:
                                    HStack {
                                        Button(action: {
                                            
                                        }) {
                                            Image("ico-nav-compare")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                        }
                                        Button("Share") {
                                            
                                        }
                                    }
            )
        }
    }
}
