import SwiftUI
import ComposableArchitecture
import Form

public struct PhotoShareState: Equatable {
    var photo: PhotoViewModel
    var message: String = ""
    
    init(photo: PhotoViewModel) {
        self.photo = photo
    }
}

public enum PhotoShareAction {
    case share
    case textFieldChanged
    case selectedItem
}

struct PhotoShareView: View {
    let store: Store<PhotoShareState, PhotoShareAction>
    
    var body: some View {
        return WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Spacer()
                        .frame(width: 20, height: 120)
                    PhotoCell(photo: viewStore.photo)
                        .frame(width: 60, height: 60, alignment: .leading)
                    TextField("Say something abouth your photo",
                              text: viewStore.binding(get: { $0.message }, send: PhotoShareAction.textFieldChanged))
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: 120, alignment: .leading)
                
                Spacer()
                
            }.navigationBarTitle("Status Update")
            .navigationBarItems(leading: Button("Back") {
                
            })
            .navigationBarItems(trailing:
                                    Button("Share") {
                                    })
        }
    }
}
