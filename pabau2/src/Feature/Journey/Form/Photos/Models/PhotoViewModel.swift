import Model
import PencilKit

public struct PhotoViewModel: Equatable {
	
	let basePhoto: Photo
	let imageData: Data?
	var drawing: PKDrawing?

	init (_ savedPhoto: SavedPhoto) {
		self.basePhoto = .saved(savedPhoto)
		self.imageData = nil
		self.drawing = nil
	}
}

extension PhotoViewModel: Identifiable {
	public var id: PhotoVariantId {
		basePhoto.id
	}
}
