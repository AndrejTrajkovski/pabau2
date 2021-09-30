import SwiftUI
import Model
import SDWebImageSwiftUI
import ComposableArchitecture

public struct SavedPhotoCell: View {
    public init(savedPhoto: SavedPhoto,
                shouldShowThumbnail: Bool) {
        self.savedPhoto = savedPhoto
        self.shouldShowThumbnail = shouldShowThumbnail
    }
    
    let savedPhoto: SavedPhoto
    let shouldShowThumbnail: Bool

    func urlString() -> String? {
        if shouldShowThumbnail {
            return savedPhoto.thumbnail
        } else {
            return savedPhoto.normalSizePhoto
        }
    }

    public var body: some View {
        WebImage(url: URL(string: urlString() ?? ""))
//            .onSuccess(perform: { _, data, _ in
//                guard let data = data else { return }
//                onDownloadPhoto?(data)
//            })
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipped()
    }
}
