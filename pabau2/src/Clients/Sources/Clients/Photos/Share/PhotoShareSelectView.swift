import SwiftUI
import ComposableArchitecture
import Model
import Util
import Form


struct PhotoShareSelectItem: Equatable, Identifiable {
    enum PhotoShareSelectItemType: Equatable {
        case title(String)
        case subtitle
        case review
        case rating
        
    }
    let id = UUID()
    var type: PhotoShareSelectItemType = .title("")
    
    var photo: PhotoViewModel!
    var comparedPhoto: PhotoViewModel!
}


struct PhotoShareSelectState: Equatable {

//    var rating: CGFloat
//    var review: String
    
    var photo: PhotoViewModel!
    var comparedPhoto: PhotoViewModel!
    
    init(photo: PhotoViewModel, comparedPhoto: PhotoViewModel) {
        self.photo = photo
        self.comparedPhoto = comparedPhoto
        
        items.append(PhotoShareSelectItem(type: .title("20 Day Difference"), photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .review, photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .rating, photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .title("Botox Treatment"), photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .subtitle, photo: photo, comparedPhoto: comparedPhoto))
        items.append(PhotoShareSelectItem(type: .subtitle, photo: photo, comparedPhoto: comparedPhoto))
    }
    
    init() {
        
    }
    
    var items: [PhotoShareSelectItem] = []
    var selectedItem: PhotoShareSelectItem?
    var photoShareState: PhotoShareState = PhotoShareState()
    var isItemSelected: Bool = false
}

public enum PhotoShareSelectAction: Equatable {
    case selectedItem
    case shareAction(PhotoShareAction)
}

var photoShareSelectViewReducer: Reducer<PhotoShareSelectState, PhotoShareSelectAction, ClientsEnvironment> = Reducer.combine(
    photoShareViewReducer.pullback(
            state: \PhotoShareSelectState.photoShareState,
            action: /PhotoShareSelectAction.shareAction,
            environment: { $0 }
        ),
    
    Reducer { state, action, env in
        switch action {
        case .selectedItem:
            state.selectedItem = state.items.first!
            state.photoShareState = PhotoShareState(photo: state.photo)
            state.isItemSelected = true
        default:
            break
        }
        
        return .none
})

struct PhotoShareSelectView: View {
    
    var store: Store<PhotoShareSelectState, PhotoShareSelectAction>
    
    var layout = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        WithViewStore(self.store) { viewStore  in
            GeometryReader { geo in
                    ScrollView {
                        LazyVGrid(columns: layout, spacing: 10) {
                            ForEach(Array(viewStore.items)) { item in
                                PhotoShareCellItemView(item: item)
                                    .frame(width: geo.size.width / 2 - 30, height: geo.size.height / 3 - 30)
                                    .onTapGesture {
                                        viewStore.send(.selectedItem)
                                    }
                            }
                        }
                    }.padding(20)
                if viewStore.photoShareState != nil {
                NavigationLink.emptyHidden(viewStore.isItemSelected,
                                           PhotoShareView(store: self.store.scope(state: { $0.photoShareState},
                                                                                  action: { PhotoShareSelectAction.shareAction($0) })
                                                          ))
                }
            }.navigationBarItems(
                trailing: Button("Share") {
                    
            })
        }
    }
}
