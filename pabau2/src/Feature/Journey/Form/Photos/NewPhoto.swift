import UIKit
import PencilKit

public struct NewPhoto: PhotoVariant, Identifiable {
	public let id: UUID
	public let image: UIImage
	var drawings: [PKDrawing]
}
