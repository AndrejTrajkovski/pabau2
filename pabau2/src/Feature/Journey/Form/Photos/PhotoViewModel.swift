import Model
import PencilKit

public struct PhotoViewModel {
	let basePhoto: Photo
	let data: Data?
	var drawings: [PKDrawing]
	
	init (_ savedPhoto: SavedPhoto) {
		self.basePhoto = .saved(savedPhoto)
		self.data = nil
		self.drawings = []
	}
}
