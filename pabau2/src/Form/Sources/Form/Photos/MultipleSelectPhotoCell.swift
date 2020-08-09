import SwiftUI

public struct MultipleSelectPhotoCell: View {
	
	let photo: PhotoViewModel
	let isSelected: Bool
	
	init(
		photo: PhotoViewModel,
		isSelected: Bool
	) {
		self.photo = photo
		self.isSelected = isSelected
	}
	
	public var body: some View {
		ZStack(alignment: .bottomTrailing) {
			PhotoCell(photo: photo)
				.overlay(PrivacyOverlay(isPrivate: photo.isPrivate))
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
		}.padding()
	}
}

struct PrivacyOverlay: View {
	let isPrivate: Bool
	var body: some View {
		Group {
			if isPrivate {
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
	}
}
