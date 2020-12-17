import SwiftUI
import Photos
import ComposableArchitecture

struct ShareInstagramView: View {
    
    let viewStore: ViewStore<PhotoShareState, PhotoShareAction>
    
    private var instagramURL: URL? {
        return URL(string: "instagram://app")
    }
    
    var body: some View {
        shareToFeed()
    }

    func shareToFeed() -> some View  {
        
        if let instaURL = instagramURL, UIApplication.shared.canOpenURL(instaURL) {
            guard let image = UIImage(data: viewStore.imageData) else { return Text("") }
            do {
                try PHPhotoLibrary.shared().performChangesAndWait {
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetID = request.placeholderForCreatedAsset?.localIdentifier
                    let shareURL = "instagram://library?LocalIdentifier=" + assetID!
                    
                    if let urlForRedirect = URL(string: shareURL) {
                        UIApplication.shared.open(urlForRedirect, options: [:], completionHandler: { _ in
                            viewStore.send(.instagram(.didComplete))
                        })
                    }
                }
            } catch {
                print("Error \(error.localizedDescription)")
            }
        } else {
            print("Instagram not installed")
        }
        
        return Text("")
    }
}
