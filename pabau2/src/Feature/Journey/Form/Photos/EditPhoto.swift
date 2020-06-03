import SwiftUI
import AVFoundation

struct EditPhoto: View {
	@State private var images: [Image]
	@State private var showingImagePicker: UIImagePickerController.SourceType?
	@State private var inputImage: UIImage?

	var body: some View {
		VStack {
			images.first?
				.resizable()
				.scaledToFit()

			Button("Select Image") {
				self.showingImagePicker = .camera
			}
		}
//		.popover(isPresented: Binding(
//			get: { self.showingImagePicker == .some(.photoLibrary) },
//			set: { self.showingImagePicker = $0 == true ? .some(.photoLibrary) : nil}
//			), content: {
//				ImagePicker(image: self.$inputImage)
//		})
			.sheet(isPresented: Binding(
				get: { self.showingImagePicker == .some(.camera) },
				set: { self.showingImagePicker = $0 == true ? .some(.camera) : nil}
				),
						 onDismiss: loadImage) {
				ImagePicker(image: self.$inputImage)
		}.onAppear(perform: { self.showingImagePicker = .camera })
	}

	func loadImage() {
		guard let inputImage = inputImage else { return }
		images.append(Image(uiImage: inputImage))
	}
}

extension EditPhoto {

	func showImagePickerForCamera(_ sender: UIButton) {
		let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

		if authStatus == AVAuthorizationStatus.denied {
			let alert = UIAlertController(title: "Unable to access the Camera",
																		message: "To turn on camera access, choose Settings > Privacy > Camera and turn on Camera access for this app.",
																		preferredStyle: UIAlertController.Style.alert)

			let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
			alert.addAction(okAction)

			let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
				// Take the user to the Settings app to change permissions.
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { _ in
						// The resource finished opening.
					})
				}
			})
			alert.addAction(settingsAction)
//			present(alert, animated: true, completion: nil)
		} else if authStatus == AVAuthorizationStatus.notDetermined {
			AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
				if granted {
//					DispatchQueue.main.async {
//						self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
//					}
				}
			})
		} else {
//			showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
		}
	}
}
