import SwiftUI
import ComposableArchitecture

struct Camera: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentationMode
    let store: Store<CameraOverlayState, CameraOverlayAction>
    let viewStore: ViewStore<CameraOverlayState, CameraOverlayAction>

    init(store: Store<CameraOverlayState, CameraOverlayAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: Camera

        init(_ parent: Camera) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<Camera>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.showsCameraControls = false
        picker.allowsEditing = false
        let cameraOverlay = CameraOverlay(
            store: self.store,
            onTakePhoto: picker.takePicture
        )
        let overlay = UIHostingController(rootView: cameraOverlay)
        overlay.view.frame = (picker.cameraOverlayView?.frame)!
        overlay.view.backgroundColor = UIColor.clear
        picker.cameraOverlayView = overlay.view
        return picker
    }

    func updateUIViewController(_ picker: UIImagePickerController, context: UIViewControllerRepresentableContext<Camera>) {
        picker.cameraFlashMode = viewStore.isFlashOn ? .on : .off
        picker.cameraDevice = viewStore.frontOrRear
    }
}

// MARK: - UIImagePickerControllerDelegate
extension Camera.Coordinator {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            return
        }
        self.parent.viewStore.send(.didTakePhotoWithCamera(image))
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
