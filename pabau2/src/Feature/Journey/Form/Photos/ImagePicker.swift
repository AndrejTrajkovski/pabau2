import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
	
	@Environment(\.presentationMode) var presentationMode
	@Binding var image: UIImage?

	class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		var parent: ImagePicker

		init(_ parent: ImagePicker) {
			self.parent = parent
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
		let picker = UIImagePickerController()
//		picker.sourceType = 
		picker.delegate = context.coordinator
		picker.sourceType = .camera
		picker.showsCameraControls = false
		let overlay = UIHostingController(rootView: CameraOverlay())
		overlay.view.frame = (picker.cameraOverlayView?.frame)!
		overlay.view.backgroundColor = UIColor.clear
		picker.cameraOverlayView = overlay.view
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
		
	}
}

// MARK: - UIImagePickerControllerDelegate
extension ImagePicker.Coordinator {
		func imagePickerController(_ picker: UIImagePickerController,
															 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

			let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

			guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
				return
			}
			self.parent.image = image
	//		finishAndUpdate()
		}

		// MARK: - Utilities
		private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
			return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
		}

		private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
			return input.rawValue
		}

}
