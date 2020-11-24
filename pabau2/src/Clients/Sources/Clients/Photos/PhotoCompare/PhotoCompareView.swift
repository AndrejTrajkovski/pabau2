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
    var selectedImage: String = "emily"
    
    var images: [String] = (1...9).map { "dummy\($0)" }
    var client: Client?
}

public struct PhotosEnvironment {
    var apiClient: ClientsAPI
    var userDefaults: UserDefaultsConfig
}

var photoCompareReducer = Reducer<PhotoCompareState, PhotoCompareAction, PhotosEnvironment> { state, action, environment in
    switch action {
    case .didChangeSelectedPhoto(let image):
        state.selectedImage = image
    default:
        break
    }
    return .none
}


struct PhotoCompareView: View {
    
    let store: Store<PhotoCompareState, PhotoCompareAction>
    
    var images: [String] = (1...9).map { "dummy\($0)" }
    
    var body: some View {
        print("PhotoCompareView")
        return WithViewStore(self.store) { viewStore in
            VStack {
                ZStack {
                    Image(viewStore.selectedImage)
                        .resizable()
                    VStack {
                        Spacer()
                        Text("Today")
                            .font(.regular32)
                            .foregroundColor(.white)
                        Text("23/11/2020")
                            .foregroundColor(.white)
                        Spacer()
                            .frame(height: 20)
                    }
                }
                Spacer()
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(self.images, id: \.self) { item in
                            Button(action: {
                                viewStore.send(.didChangeSelectedPhoto(item))
                            }) {
                                Image(item)
                                    .resizable()
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
