import Model
import PencilKit

public struct PhotoViewModel: Equatable {
	
	let basePhoto: Photo
	let data: Data?
	var drawing: PKDrawing

	init (_ savedPhoto: SavedPhoto) {
		self.basePhoto = .saved(savedPhoto)
		self.data = nil
		self.drawing = PKDrawing()
	}
}

extension PhotoViewModel: Identifiable {
	public var id: PhotoVariantId {
		basePhoto.id
	}
}
