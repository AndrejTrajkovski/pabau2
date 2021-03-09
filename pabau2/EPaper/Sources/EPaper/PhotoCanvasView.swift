import SwiftUI
import SDWebImageSwiftUI
import PencilKit

struct PhotoCanvasView: View {
    var imageURL: URL
    var canvasView: PKCanvasView
    var onDrawingChange: () -> Void
    
    var body: some View {
        ZStack {
            WebImage(url: imageURL)
            EpaperCanvasView(canvasView: canvasView) {
                print("on saved")
                self.onDrawingChange()
            }
        }
    }
}
