import SwiftUI
import ComposableArchitecture

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            
        } else {
        }
    }
}

struct ImageSaveState: Equatable {
    static func == (lhs: ImageSaveState, rhs: ImageSaveState) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    var uuid: UUID = UUID()
    var didSaved: Bool = false
    var error: Error?
}
