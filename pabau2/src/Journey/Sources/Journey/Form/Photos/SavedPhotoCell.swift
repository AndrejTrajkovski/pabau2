import SwiftUI
import Model

struct SavedPhotoCell: View {
	let savedPhoto: SavedPhoto
	var body: some View {
		Image(savedPhoto.url)
			.resizable()
			.aspectRatio(contentMode: .fit)
	}
}
