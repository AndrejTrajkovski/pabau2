import Foundation
import SwiftUI
import PencilKit

class CanvasHelper {
    
    static func mergeImagesWithDrawings(images: [UIImage], canvases: [PKCanvasView]) -> [UIImage] {
        let drawingRectSize = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let canvasDrawingImages = canvases.map {
             $0.drawing.image(from: drawingRectSize, scale: 1.0)
        }
        let mergeResult = zip(images, canvasDrawingImages).map { backImage, topImage in
            backImage.mergeWith(topImage: topImage)
        }
        
        return mergeResult
    }
}

extension UIImage {
    
    /// Merge two images into one
    /// - Parameter topImage: drawing for topImage
    /// - Returns: UIImage
    func mergeWith(topImage: UIImage) -> UIImage {
        let bottomImage = self
        UIGraphicsBeginImageContext(size)
        
        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: areaSize)
        
        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }
}
