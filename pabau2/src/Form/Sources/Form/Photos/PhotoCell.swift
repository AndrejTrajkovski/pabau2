import SwiftUI
import CasePaths

public struct PhotoCell: View {
	let photo: PhotoViewModel

	public init(photo: PhotoViewModel) {
		self.photo = photo
	}

	public var body: some View {
        switch photo.basePhoto {
        case .saved(let savedPhoto):
            SavedPhotoCell(savedPhoto: savedPhoto)
        case .new(let newPhoto):
            NewPhotoCell(newPhoto: newPhoto)
        }
	}
}
