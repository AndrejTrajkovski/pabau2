import SwiftUI
import ModelPackage

struct SavedPhotoCell: View {
	let savedPhoto: SavedPhoto
	var body: some View {
		Image(savedPhoto.url)
			.resizable()
			.aspectRatio(contentMode: .fit)
	}
}
