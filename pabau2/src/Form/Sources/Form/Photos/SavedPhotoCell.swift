import SwiftUI
import Model
import SDWebImageSwiftUI
import ComposableArchitecture

public enum SavedPhotoAction: Equatable {
    case onDowndloadPhoto(Data)
}

public struct SavedPhotoStoreCell: View {

    public init(store: Store<SavedPhoto, SavedPhotoAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    let store: Store<SavedPhoto, SavedPhotoAction>
    @ObservedObject var viewStore: ViewStore<SavedPhoto, SavedPhotoAction>

    public var body: some View {
        SavedPhotoCell.init(savedPhoto: viewStore.state,
                            onDownloadPhoto: {
                                viewStore.send(.onDowndloadPhoto($0))
                            })
    }
}

public struct SavedPhotoCell: View {
    public init(savedPhoto: SavedPhoto,
                onDownloadPhoto: ((Data) -> Void)? = nil) {
        self.savedPhoto = savedPhoto
        self.onDownloadPhoto = onDownloadPhoto
    }
    
    let savedPhoto: SavedPhoto
    let onDownloadPhoto: ((Data) -> Void)?

    public var body: some View {
        WebImage(url: URL(string: savedPhoto.normalSizePhoto ?? ""))
            .onSuccess(perform: { _, data, _ in
                guard let data = data else { return }
                onDownloadPhoto?(data)
            })
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipped()
    }
}
