import Model
import PencilKit

public struct PhotoViewModel: Hashable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(basePhoto.id)
		hasher.combine(data)
	}
	
	let basePhoto: Photo
	let data: Data?
	var drawing: PKDrawing?
	
	init (_ savedPhoto: SavedPhoto) {
		self.basePhoto = .saved(savedPhoto)
		self.data = nil
		self.drawing = nil
	}
}

extension PhotoViewModel: Identifiable {
	public var id: PhotoVariantId {
		basePhoto.id
	}
}
