import UIKit
import AVFoundation

//Serves also as an underlying view of the camera
//class EditPhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//
//	var openCameraImmediately: Bool = false
//	var overlayView: CameraOverlayView!
//	var imagePickerController = UIImagePickerController()
//
//	var capturedImages = [UIImage]()
//
//	override func viewDidLoad() {
//		overlayView = CameraOverlayView()
//		if openCameraImmediately {
//			self.showImagePicker(sourceType: .camera, button: nil)
//		}
//	}
//
//	func showImagePickerForCamera(_ sender: UIButton) {
//		let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
//
//		if authStatus == AVAuthorizationStatus.denied {
//			let alert = UIAlertController(title: "Unable to access the Camera",
//																		message: "To turn on camera access, choose Settings > Privacy > Camera and turn on Camera access for this app.",
//																		preferredStyle: UIAlertController.Style.alert)
//
//			let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//			alert.addAction(okAction)
//
//			let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
//				// Take the user to the Settings app to change permissions.
//				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
//				if UIApplication.shared.canOpenURL(settingsUrl) {
//					UIApplication.shared.open(settingsUrl, completionHandler: { _ in
//						// The resource finished opening.
//					})
//				}
//			})
//			alert.addAction(settingsAction)
//
//			present(alert, animated: true, completion: nil)
//		} else if authStatus == AVAuthorizationStatus.notDetermined {
//			AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
//				if granted {
//					DispatchQueue.main.async {
//						self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
//					}
//				}
//			})
//		} else {
//			showImagePicker(sourceType: UIImagePickerController.SourceType.camera, button: sender)
//		}
//	}
//
//	func showImagePicker(sourceType: UIImagePickerController.SourceType, button: UIButton?) {
//		if !capturedImages.isEmpty {
//			capturedImages.removeAll()
//		}
//
//		imagePickerController.sourceType = sourceType
//		imagePickerController.modalPresentationStyle =
//			(sourceType == UIImagePickerController.SourceType.camera) ?
//				UIModalPresentationStyle.fullScreen : UIModalPresentationStyle.popover
//		let presentationController = imagePickerController.popoverPresentationController
//        // Display a popover from the UIBarButtonItem as an anchor.
//		presentationController?.sourceView = button ?? self.view
//		presentationController?.sourceRect = button?.bounds ?? self.view.bounds
//
//		presentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
//		if sourceType == UIImagePickerController.SourceType.camera {
//			imagePickerController.showsCameraControls = true
//			overlayView?.frame = (imagePickerController.cameraOverlayView?.frame)!
//			imagePickerController.cameraOverlayView = overlayView
//		}
//		present(imagePickerController, animated: true, completion: {
//			// The block to execute after the presentation finishes.
//		})
//	}
//}
