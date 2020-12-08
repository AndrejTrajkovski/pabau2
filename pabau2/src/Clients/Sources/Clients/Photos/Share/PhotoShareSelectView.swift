import SwiftUI
import ComposableArchitecture
import Model
import Util
import Form


struct PhotoShareSelectItem: Equatable, Identifiable {
    enum PhotoShareSelectItemType {
        case title
        case subtitle
        case review
        case rating
    }
    let id = UUID()
    var type: PhotoShareSelectItemType = .title
}


struct PhotoShareSelectState: Equatable {

    
//    var photoBefore: PhotoViewModel
//    var photoAfter: PhotoViewModel
//    var dateBefore: Date
//    var dateAfter: Date
//    var rating: CGFloat
//    var review: String
    
    var photo: PhotoViewModel
    
    var items: [PhotoShareSelectItem] = [PhotoShareSelectItem(), PhotoShareSelectItem(type: .review), PhotoShareSelectItem(type: .rating), PhotoShareSelectItem(), PhotoShareSelectItem(), PhotoShareSelectItem()]
    
    var selectedItem: PhotoShareSelectItem?
    
    var photoShareState: PhotoShareState!
    
    var isItemSelected: Bool = false
}

var photoShareSelectViewReducer = Reducer<PhotoShareSelectState, PhotoShareAction, ClientsEnvironment> { state, action, env in
    switch action {
    case .selectedItem:
        state.selectedItem = state.items.first!
        state.photoShareState = PhotoShareState(photo: state.photo)
        state.isItemSelected = true
    default:
        break
    }
    return .none
}

struct PhotoShareSelectView: View {
    
    var store: Store<PhotoShareSelectState, PhotoShareAction>
    
    var layout = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        WithViewStore(self.store) { viewStore  in
            GeometryReader { geo in
                    ScrollView {
                        LazyVGrid(columns: layout, spacing: 10) {
                            ForEach(Array(viewStore.items)) { item in
                                PhotoShareCellItemView(item: item)
                                    .frame(width: geo.size.width / 2, height: geo.size.height / 3 - 10)
                                    .onTapGesture {
                                        viewStore.send(.selectedItem)
                                    }
                            }
                        }
                    }
                if viewStore.photoShareState != nil {
                NavigationLink.emptyHidden(viewStore.isItemSelected,
                                           //EmptyView())
                                           PhotoShareView(store: self.store.scope(state: { $0.photoShareState},
                                                                                  action: { $0 })
                                                          ))
                }
            }.navigationBarItems(
                trailing: Button("Share") {
                    
            })
        }
    }
}
