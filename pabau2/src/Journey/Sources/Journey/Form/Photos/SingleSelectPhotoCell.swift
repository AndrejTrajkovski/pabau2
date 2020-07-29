import SwiftUI

struct SingleSelectPhotoCell: View {
	let photo: PhotoViewModel
	let isSelected: Bool
	var body: some View {
		PhotoCell(photo: photo)
			.border(isSelected ? Color.accentColor : Color.clear, width: 8.0)
	}
}
