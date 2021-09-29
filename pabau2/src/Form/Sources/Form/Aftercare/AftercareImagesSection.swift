import SwiftUI
import ComposableArchitecture
import Model
import SDWebImageSwiftUI

public let singleSelectImagesReducer = Reducer<SingleSelectImages, SingleSelectImagesAction, Any>.init { state, action, _ in
    switch action {
    case .didSelectIdx(let idx):
        state.selectedIdx = state.selectedIdx == idx ? nil : idx
    }
    return .none
}

public struct SingleSelectImages: Equatable {
    let images: [SavedPhoto]
    var selectedIdx: Int?
    
    func isSelected(model: SavedPhoto) -> Bool {
        return self.images.firstIndex(of: model) == selectedIdx
    }
    
    public init (images: [SavedPhoto],
                 selectedIdx: Int?) {
        self.images = images
        self.selectedIdx = selectedIdx
    }
}

public enum SingleSelectImagesAction: Equatable {
    case didSelectIdx(Int)
}

struct AftercareImagesSection: View {
    
    init(title: String, store: Store<SingleSelectImages, SingleSelectImagesAction>) {
        self.title = title
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    let title: String
    let store: Store<SingleSelectImages, SingleSelectImagesAction>
    
    
    @ObservedObject var viewStore: ViewStore<SingleSelectImages, SingleSelectImagesAction>
    
    var body: some View {
        Section(header: AftercareTitle(self.title)) {
            ForEach(viewStore.state.images.indices) { idx in
                let model = viewStore.state.images[idx]
                GridCell(model: model,
                         isSelected: self.viewStore.state.isSelected(model: model))
                    .onTapGesture {
                        self.viewStore.send(.didSelectIdx(idx))
                    }
                
            }
        }
    }
}

struct GridCell: View {
    let model: SavedPhoto
    let isSelected: Bool
    var body: some View {
        WebImage(url: model.thumbnail.flatMap(URL.init(string:)))
            .resizable()
            .indicator(.activity) // Activity Indicator
            .padding(8)
            .border(isSelected ? Color.accentColor : Color.clear, width: 8.0)
    }
}
