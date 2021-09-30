import SwiftUI
import CasePaths

public struct PhotoCell: View {
	let photo: PhotoViewModel
    let shouldShowThumbnail: Bool

	public init(photo: PhotoViewModel,
                shouldShowThumbnail: Bool) {
		self.photo = photo
        self.shouldShowThumbnail = shouldShowThumbnail
	}

	public var body: some View {
        switch photo.basePhoto {
        case .saved(let savedPhoto):
            SavedPhotoCell(savedPhoto: savedPhoto, shouldShowThumbnail: shouldShowThumbnail)
        case .new(let newPhoto):
            NewPhotoCell(newPhoto: newPhoto)
        }
	}
}
