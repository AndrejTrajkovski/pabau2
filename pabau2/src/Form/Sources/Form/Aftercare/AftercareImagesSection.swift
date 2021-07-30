import SwiftUI
import ComposableArchitecture
import ASCollectionView
import Model

public let singleSelectImagesReducer = Reducer<SingleSelectImages, SingleSelectImagesAction, Any>.init { state, action, _ in
	switch action {
	case .didSelectIdx(let idx):
		state.selectedIdx = state.selectedIdx == idx ? nil : idx
	}
	return .none
}

public struct SingleSelectImages: Equatable {
    let images: [ImageModel]
    var selectedIdx: Int?
    
    func isSelected(url: ImageModel) -> Bool {
        return self.images.firstIndex(of: url) == selectedIdx
    }
    
    public init (images: [ImageModel],
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
                let imageUrl = viewStore.state.images[idx]
                GridCell(title: imageUrl.title,
                         isSelected: self.viewStore.state.isSelected(url: imageUrl))
                    .onTapGesture {
                        self.viewStore.send(.didSelectIdx(idx))
                    }
                
            }
        }
    }
}

struct GridCell: View {
	let title: String
	let isSelected: Bool
	var body: some View {
		Image(title)
		.resizable()
		.aspectRatio(contentMode: .fit)
		.padding(8)
		.border(isSelected ? Color.accentColor : Color.clear, width: 8.0)
	}
}
