import Model
import PencilKit

public struct PhotoViewModel: PhotoVariant {
	let basePhoto: JourneyPhotos
	let data: Data?
	var drawings: [PKDrawing]
	
	init (_ basePhoto: JourneyPhotos) {
		self.basePhoto = basePhoto
		self.data = nil
		self.drawings = []
	}
}

extension PhotoViewModel: Identifiable {
	public var id: Int { basePhoto.id }
}
