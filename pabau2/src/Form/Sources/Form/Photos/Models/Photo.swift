import Model
import Foundation

@dynamicMemberLookup
public enum Photo: Equatable {
	case saved(SavedPhoto)
	case new(NewPhoto)
}

extension Photo: Identifiable {
	public var id: PhotoVariantId {
		switch self {
		case .new(let newPhoto):
			return PhotoVariantId.new(newPhoto.id)
		case .saved(let savedPhoto):
            return PhotoVariantId.saved(savedPhoto.id)
		}
	}
}

extension Photo {
	public subscript<T>(dynamicMember keyPath: KeyPath<PhotoVariant, T>) -> T {
			switch self {
			case .saved(let saved):
                return saved[keyPath: keyPath]
			case .new(let new):
					return new[keyPath: keyPath]
			}
	}
}

extension SavedPhoto: PhotoVariant {
    public var date: Date {
        return photoDate
    }
}
