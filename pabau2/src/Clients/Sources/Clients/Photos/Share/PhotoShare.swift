import SwiftUI
import ComposableArchitecture
import Form
import Util
import UIKit

public struct PhotoShareState: Equatable {
    var photo: PhotoViewModel!
    var message: String = ""
    
    var isMessagePosted: Bool = false
    var shouldDisplayActivity: Bool = false
    
//    init(photo: PhotoViewModel) {
//        self.photo = photo
//    }
}

public enum PhotoShareAction {
    case share
    case textFieldChanged
    case messagePosted
    case backButton
}

var photoShareViewReducer = Reducer<PhotoShareState, PhotoShareAction, ClientsEnvironment> { state, action, env in
    switch action {
    case .messagePosted:
        state.isMessagePosted = !state.isMessagePosted
    default:
        break
    }
    return .none
}

struct PhotoShareView: View {
    let store: Store<PhotoShareState, PhotoShareAction>
    
    @State var isShownActivity: Bool = false
    
    var body: some View {
        return WithViewStore(store) { viewStore in

            ZStack {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 5) {
                        Spacer()
                            .frame(width: 20, height: 120)
                        PhotoCell(photo: viewStore.photo)
                            .frame(width: 60, height: 60, alignment: .leading)
                        TextField("Say something abouth your photo",
                                  text: viewStore.binding(get: { $0.message },
                                                          send: PhotoShareAction.textFieldChanged))
                            .font(Font.regular14)
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 120, alignment: .leading).padding()
                    .background(Color.white)
                    
                    Divider()
                    
                    HStack {
                        Text("Share with:")
                            .font(Font.regular14)
                            .fontWeight(.regular)
                        Spacer()
                        
                        Button(action: {
                        }) {
                            Text("MyFitnessPal Community")
                                .font(Font.regular16)
                                .fontWeight(.regular).foregroundColor(.blue)
                        }
                    }.padding()
                    .frame(width: UIScreen.main.bounds.width, height: 50, alignment: .leading)
                    .background(Color.white)
                    Divider()
                    Spacer().frame(height: 30)
                    
                    VStack(spacing: 1) {
                        Divider()
                        HStack(alignment: .center, spacing: 2) {
                            Spacer()
                                .frame(width: 15)
                            Button(action: {
                            }) {
                                SocialTitleImage(imageName: "ico-share-facebook", socialMediaTitle: "Facebook", isSystemIcon: false)
                            }
                            SocialTitleImage(imageName: "ico-share-instagram", socialMediaTitle: "Instagram", isSystemIcon: false)
                        }
                        Divider()
                        HStack(alignment: .center, spacing: 2) {
                            Spacer()
                                .frame(width: 15)
                            Button(action: {
                                viewStore.send(.messagePosted)
                            }) {
                                SocialTitleImage(imageName: "photo", socialMediaTitle: "Save to Camera", isSystemIcon: true)
                            }
                            Button(action: {
                                self.isShownActivity = true
                            }) {
                                SocialTitleImage(imageName: "ellipsis", socialMediaTitle: "More", isSystemIcon: true)
                            }
                        }
                        Divider()
                    }
                    .frame(height: 120)
                    .padding(2)
                    
                    Spacer()
                    
                }.sheet(isPresented: $isShownActivity, content: {
                    if extract(case: Photo.saved, from: viewStore.photo.basePhoto) != nil {
                        if let savedPhoto = extract(case: Photo.saved, from: viewStore.photo.basePhoto) {
                            ActivityViewController(activityItems: [UIImage(named: savedPhoto.url)!, "Say something"])
                        }

                    }
                    
                })
                
                if viewStore.isMessagePosted {
                    MessagePostView()
                        .onTapGesture {
                            viewStore.send(.messagePosted)
                        }
                }
                
            }.background(Color.paleGrey)
            .navigationBarTitle("Status Update").font(Font.semibold17)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: HStack {
                    MyBackButton(text: Texts.back) {
                        viewStore.send(.backButton)
                    }
                },

                trailing: HStack {
                    Button("Share") {
                        print("Share")
                    }.font(Font.regular17)
                })
        }
    }
}

struct SocialTitleImage: View {
    
    let imageName: String
    let socialMediaTitle: String
    let isSystemIcon: Bool
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: 12) {
                if isSystemIcon {
                    Image(systemName: imageName)
                } else {
                    Image(imageName).resizable().frame(width: 26, height: 26).aspectRatio(contentMode: .fit)
                }
                
                Text(socialMediaTitle)
                    .font(Font.regular14)
                    .fontWeight(.regular)
                Spacer()
            
            }.padding(.leading, 10)
            .frame(width: geo.size.width, height: 60)
            .background(Color.white)
        }
        
    }
    
}