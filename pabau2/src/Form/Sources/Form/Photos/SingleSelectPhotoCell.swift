import SwiftUI

public struct SingleSelectPhotoCell: View {
	let photo: PhotoViewModel
	let isSelected: Bool
	public var body: some View {
		PhotoCell(photo: photo)
			.border(isSelected ? Color.accentColor : Color.clear, width: 8.0)
	}
}
