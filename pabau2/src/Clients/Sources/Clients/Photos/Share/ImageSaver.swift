import SwiftUI
import ComposableArchitecture

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) -> Effect<PhotoShareAction, Never> {
        return Effect<PhotoShareAction, Never>.future { callback in
            self.successHandler = {
                callback(.success(.saveToCamera(.success)))
            }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveError), nil)
        }
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            
        } else {
            successHandler?()
        }
    }
}
