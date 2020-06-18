import SwiftUI

struct NewPhotoCell: View {
	let newPhoto: NewPhoto
	var body: some View {
		Image(uiImage: newPhoto.image)
			.resizable()
			.aspectRatio(contentMode: .fit)
	}
}
