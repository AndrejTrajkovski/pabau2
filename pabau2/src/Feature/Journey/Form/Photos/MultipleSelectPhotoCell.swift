import SwiftUI

struct MultipleSelectPhotoCell: View {
	let photo: PhotoViewModel
	let isSelected: Bool
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			PhotoCell(photo: photo)
			if isSelected {
				ZStack {
					Circle()
						.fill(Color.blue)
					Circle()
						.strokeBorder(Color.white, lineWidth: 2)
					Image(systemName: "checkmark")
						.font(.system(size: 10, weight: .bold))
						.foregroundColor(.white)
				}
				.frame(width: 20, height: 20)
				.padding(10)
			}
		}
	}
}
