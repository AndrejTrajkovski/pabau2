import SwiftUI

struct NewPhotoCell: View {
	let newPhoto: NewPhoto
	var body: some View {
		Image(uiImage: newPhoto.image)
			.resizable()
			.aspectRatio((
				newPhoto.image.size.width / newPhoto.image.size.height),
									 contentMode: .fit)
	}
}
