import SwiftUI
import Model
import SDWebImageSwiftUI
import ComposableArchitecture

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
