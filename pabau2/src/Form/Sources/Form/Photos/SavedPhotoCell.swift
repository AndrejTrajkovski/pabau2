import SwiftUI
import Model
import SDWebImageSwiftUI

public struct SavedPhotoCell: View {
    public init(savedPhoto: SavedPhoto) {
        self.savedPhoto = savedPhoto
    }
    
    let savedPhoto: SavedPhoto
    public var body: some View {
//		GeometryReader { proxy in
			WebImage(url: URL(string: savedPhoto.normalSizePhoto ?? ""))
				.resizable()
				.aspectRatio(contentMode: .fit)
//				.frame(width: proxy.size.width, height: proxy.size.height)
				.clipped()
//		}
	}
}
