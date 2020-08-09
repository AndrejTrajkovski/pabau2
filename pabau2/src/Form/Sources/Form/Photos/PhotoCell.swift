import SwiftUI
import CasePaths

public struct PhotoCell: View {
	let photo: PhotoViewModel
	
	public init(photo: PhotoViewModel) {
		self.photo = photo
	}
	
	public var body: some View {
		Group {
			if extract(case: Photo.saved, from: photo.basePhoto) != nil {
				SavedPhotoCell(savedPhoto: extract(case: Photo.saved, from: photo.basePhoto)!)
			} else if extract(case: Photo.new, from: photo.basePhoto) != nil {
				NewPhotoCell(newPhoto: extract(case: Photo.new, from: photo.basePhoto)!)
			}
		}
	}
}
