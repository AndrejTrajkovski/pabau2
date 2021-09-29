import SwiftUI
import ComposableArchitecture
import Model
import SDWebImageSwiftUI

public let singleSelectImagesReducer: Reducer<SingleSelectImages, SingleSelectImagesAction, Any> =
    .init { state, action, _ in
        switch action {
        case .rows(let id, _):
            state.selectedId = id
        }
        return .none
    }

public struct SingleSelectImages: Equatable {
    var images: IdentifiedArrayOf<SavedPhoto>
    var selectedId: SavedPhoto.ID?
    
    public init (images: IdentifiedArrayOf<SavedPhoto>,
                 selectedId: SavedPhoto.ID?) {
        self.images = images
        self.selectedId = selectedId
    }

    var rows: IdentifiedArrayOf<GridCellState> {
        get {
            let gridImages = images.map { GridCellState.init(photo: $0, selectedId: selectedId) }
            return IdentifiedArray.init(uniqueElements: gridImages)
        }
        set {
            self.images = IdentifiedArray.init(uniqueElements: newValue.map(\.photo))
            self.selectedId = newValue.first(where: { $0.selectedId != nil })?.id
        }
    }
}

public enum SingleSelectImagesAction: Equatable {
    case rows(id: SavedPhoto.ID, select: SelectAction)
}

public struct SelectAction: Equatable {}

struct AftercareImagesSection: View {
    
    init(title: String, store: Store<SingleSelectImages, SingleSelectImagesAction>) {
        self.title = title
        self.store = store
    }
    
    let title: String
    let store: Store<SingleSelectImages, SingleSelectImagesAction>
    
    var body: some View {
        Section(header: AftercareTitle(self.title)) {
            ForEachStore(store.scope(state: { $0.rows },
                                     action: SingleSelectImagesAction.rows),
                         content: GridCell.init(store:))
        }
    }
}

struct GridCellState: Equatable, Identifiable {
    let photo: SavedPhoto
    let selectedId: SavedPhoto.ID?

    var id: SavedPhoto.ID { photo.id }
}

struct GridCell: View {

    let store: Store<GridCellState, SelectAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            WebImage(url: viewStore.photo.thumbnail.flatMap(URL.init(string:)))
                .resizable()
                .indicator(.activity) // Activity Indicator
                .padding(8)
                .border((viewStore.selectedId != nil) ? Color.accentColor : Color.clear, width: 8.0)
                .onTapGesture {
                    viewStore.send(SelectAction())
                }
        }.id(UUID())
    }
}
