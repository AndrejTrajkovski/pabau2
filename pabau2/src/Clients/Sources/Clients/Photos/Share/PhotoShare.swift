import SwiftUI
import ComposableArchitecture
import Form
import Util
import UIKit

public struct PhotoShareState: Equatable {
    var message: String = ""

    var isMessagePosted: Bool = false
    var shouldDisplayActivity: Bool = false
    var shouldDisplayFacebookDialog: Bool = false
    var shouldDisplaySuccessMessage: Bool = false
    var shouldDisplayInstagramDialog: Bool = false

    var messageSuccess: MessageSuccessInfo = MessageSuccessInfo()

    var imageData: Data!
}

public struct MessageSuccessInfo: Equatable {
    var title: String = ""
    var subtitle: String = ""
}

public enum PhotoShareAction: Equatable {
    case textFieldChanged(String)
    case messagePosted
    case backButton
    case facebook(ShareSocialAction)
    case instagram(ShareSocialAction)
    case saveToCamera(SaveAlbumAction)
    case hideMessageView

    public enum ShareSocialAction {
        case display
        case didCancel
        case didComplete
        case didFailed
    }

    public enum SaveAlbumAction {
        case save
        case success
        case error
    }

}

var photoShareViewReducer = Reducer<PhotoShareState, PhotoShareAction, ClientsEnvironment> { state, action, _ in
    switch action {
    case .messagePosted:
        state.isMessagePosted = !state.isMessagePosted
    case .facebook(.display):
        state.shouldDisplayFacebookDialog = !state.shouldDisplayFacebookDialog
    case .facebook(.didCancel):
        state.shouldDisplayFacebookDialog = false
    case .facebook(.didComplete):
        state.shouldDisplayFacebookDialog = false
        state.messageSuccess = MessageSuccessInfo(title: "Succesfully shared an image",
                                                  subtitle: "Your images has been shared on Facebook")
        state.shouldDisplaySuccessMessage = true
    case .facebook(.didFailed):
        state.shouldDisplayFacebookDialog = false
    case .instagram(.display):
            state.shouldDisplayInstagramDialog = !state.shouldDisplayInstagramDialog
        case .instagram(.didComplete):
            state.shouldDisplayInstagramDialog = false
    case .saveToCamera(.save):
        if let uiImage = UIImage(data: state.imageData) {
            return ImageSaver().writeToPhotoAlbum(image: uiImage)
        }
    case .saveToCamera(.success):
        state.messageSuccess = MessageSuccessInfo(title: "Succesfully saved the image.",
                                                  subtitle: "Your images has been saved locally")
        state.shouldDisplaySuccessMessage = true
    case .hideMessageView:
        state.shouldDisplaySuccessMessage = false
    case .textFieldChanged(let text):
        state.message = text
    default:
        break
    }
    return .none
}

struct PhotoShareView: View {
    let store: Store<PhotoShareState, PhotoShareAction>
    @ObservedObject var viewStore: ViewStore<PhotoShareState, PhotoShareAction>

    init(store: Store<PhotoShareState, PhotoShareAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    @State var isShownActivity: Bool = false

    var body: some View {
            ZStack {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 5) {
                        Spacer()
                            .frame(width: 20, height: 120)
                        Image(uiImage: UIImage(data: viewStore.imageData)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 80, alignment: .leading)
                        TextField("Say something abouth your photo",
                                  text: viewStore.binding(get: { $0.message },
                                                          send: PhotoShareAction.textFieldChanged)
                                  )
                            .font(.proRegular(size: 14))
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
                                .fontWeight(.regular)
                                .foregroundColor(.blue)
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
                                viewStore.send(.facebook(.display))
                            }) {
                                SocialTitleImage(imageName: "ico-share-facebook", socialMediaTitle: "Facebook", isSystemIcon: false)
                            }
                            Button(action: {
                                viewStore.send(.instagram(.display))
                            }) {
                                SocialTitleImage(imageName: "ico-share-instagram", socialMediaTitle: "Instagram", isSystemIcon: false)
                            }
                        }
                        Divider()
                        HStack(alignment: .center, spacing: 2) {
                            Spacer()
                                .frame(width: 15)
                            Button(action: {
                                viewStore.send(.saveToCamera(.save))
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

                }.sheet(isPresented: $isShownActivity) {
                    if let image = UIImage(data: viewStore.imageData) {
                        ActivityViewController(activityItems: [image])
                    }
                }

                if viewStore.shouldDisplaySuccessMessage {
                    MessagePostView(param: viewStore.messageSuccess)
                        .onTapGesture {
                            viewStore.send(.hideMessageView)
                        }
                }

                if viewStore.shouldDisplayFacebookDialog {
                    ShareFacebookViewController(viewStore: viewStore)
                }
                if viewStore.shouldDisplayInstagramDialog {
                    ShareInstagramView(viewStore: viewStore)
                }

            }.background(Color.paleGrey)
            .navigationBarTitle("Status Update")
            .font(Font.semibold17)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: HStack {
                    MyBackButton(text: Texts.back) {
                        viewStore.send(.backButton)
                    }
                })
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
