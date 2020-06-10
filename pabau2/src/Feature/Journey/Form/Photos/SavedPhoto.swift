import Model
import PencilKit

public struct SavedPhoto: PhotoVariant {
	let basePhoto: JourneyPhotos
	let data: Data?
	var drawings: [PKDrawing]
}

extension SavedPhoto: Identifiable {
	public var id: Int { basePhoto.id }
}
