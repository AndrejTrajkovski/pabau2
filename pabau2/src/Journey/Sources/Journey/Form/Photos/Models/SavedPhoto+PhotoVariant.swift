import Model
import Foundation

extension SavedPhoto: PhotoVariant {
	var date: Date { dateTaken}
}
