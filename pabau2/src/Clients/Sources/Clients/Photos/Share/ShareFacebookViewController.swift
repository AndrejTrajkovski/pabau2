import SwiftUI
import UIKit
import FacebookShare
import FBSDKShareKit
import ComposableArchitecture

struct ShareFacebookViewController: UIViewControllerRepresentable {

    var viewStore: ViewStore<PhotoShareState, PhotoShareAction>

    func makeUIViewController(context: Context) -> UIViewController {
        let alertvc = AlertDialogViewController(viewStore: viewStore)

        return alertvc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }

}

class AlertDialogViewController: UIViewController {

    var content: SharePhotoContent!
    var dialog: ShareDialog!

    let viewStore: ViewStore<PhotoShareState, PhotoShareAction>
    init(viewStore: ViewStore<PhotoShareState, PhotoShareAction>) {
        self.viewStore = viewStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        content = SharePhotoContent()
        let image: UIImage = UIImage(data: viewStore.imageData)!

        let photo = SharePhoto()
        photo.image = image
        photo.isUserGenerated = true
        content.photos = [photo]

        dialog = ShareDialog()
        dialog.fromViewController = self
        dialog.shareContent = content
        dialog.mode = ShareDialog.Mode.shareSheet
        dialog.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        dialog.show()
    }

}

extension AlertDialogViewController: SharingDelegate {
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String: Any]) {
        viewStore.send(.facebook(.didComplete))
    }

    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        viewStore.send(.facebook(.didFailed))
    }

    func sharerDidCancel(_ sharer: Sharing) {
        viewStore.send(.facebook(.didCancel))
    }
}
