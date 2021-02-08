import SwiftUI
import Model
import SDWebImageSwiftUI

struct SavedPhotoCell: View {
    let savedPhoto: SavedPhoto
    var body: some View {
        GeometryReader { proxy in
        WebImage(url: URL(string: savedPhoto.normalSizePhoto ?? ""))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }
}
