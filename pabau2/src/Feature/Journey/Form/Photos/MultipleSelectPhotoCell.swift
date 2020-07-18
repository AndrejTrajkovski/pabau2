import SwiftUI

struct MultipleSelectPhotoCell: View {
	let photo: PhotoViewModel
	let isSelected: Bool
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			PhotoCell(photo: photo)
				.overlay(
					Group {
						if photo.isPrivate {
							VStack {
								Image(systemName: "eye.slash.fill")
									.foregroundColor(.blue)
									.font(.system(size: 32))
								Text("Private photo")
							}
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(Color.white)
							.border(Color.blue, width: 0.5)
						}
					}
			)
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
