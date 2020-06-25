import Model
import PencilKit

public struct PhotoViewModel: Equatable {
	let basePhoto: Photo
	var drawing: PKDrawing?
	var isPrivate: Bool = false
	var tags: [String] = []
	var injections: [Injection]

	init (_ savedPhoto: SavedPhoto) {
		self.basePhoto = .saved(savedPhoto)
		self.drawing = nil
		self.injections = []
	}

	init (_ newPhoto: NewPhoto) {
		self.basePhoto = .new(newPhoto)
		self.drawing = nil
		self.injections = []
	}
}

extension PhotoViewModel: Identifiable {
	public var id: PhotoVariantId {
		basePhoto.id
	}
}
