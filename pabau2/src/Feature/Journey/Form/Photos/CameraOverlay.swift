import SwiftUI

struct CameraOverlay: View {
	var body: some View {
		VStack {
			TopButtons()
			Spacer()
			StencilsCollection()
			BottomButtons()
		}
		.buttonStyle(CameraButtonStyle())
	}
}

private struct StencilsCollection: View {
	var body: some View {
		HStack {
			ForEach(1..<10) { index in
				Image("dummy\(index)")
				.resizable()
				.frame(width: 62, height: 74)
			}
		}.padding()
	}
}

private struct TopButtons: View {
	var body: some View {
		HStack {
			Button.init(action: { }, label: {
				Image(systemName: "xmark.circle.fill")
			})
			Spacer()
			Button.init(action: { }, label: {
				Text("Edit")
			})
			Button.init(action: { }, label: {
				Image(systemName: "tag")
			})
			Button.init(action: { }, label: {
				Image(systemName: "eye.slash")
			})
			Button.init(action: { }, label: {
				Image(systemName: "camera")
			})
			Button.init(action: { }, label: {
				Image(systemName: "bolt")
			})
		}.padding()
	}
}

private struct BottomButtons: View {
	var body: some View {
		HStack {
			Button.init(action: { }, label: {
				Image(systemName: "wand.and.stars")
			})
			Button.init(action: { }, label: {
				Image("ico-journey-upload-photos-take-a-photo")
			})
			Button.init(action: { }, label: {
				Image(systemName: "photo.on.rectangle")
			})
		}.padding()
	}
}

private struct CameraButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(width: 44, height: 44)
			.foregroundColor(Color.white)
			.background(Color.black.opacity(0.2))
			.clipShape(Circle())
	}
}

//#if DEBUG
//struct CameraOverlay_Preview: PreviewProvider {
//  static var previews: some View {
//    CameraOverlay()
//  }
//}

//#endif
