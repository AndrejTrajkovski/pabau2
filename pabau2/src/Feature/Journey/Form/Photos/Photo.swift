import Model

@dynamicMemberLookup
public enum Photo: Equatable {
	case saved(SavedPhoto)
	case new(NewPhoto)
}

extension SavedPhoto: PhotoVariant {
	var date: Date { dateTaken}
}

extension Photo {
	subscript<T>(dynamicMember keyPath: KeyPath<PhotoVariant, T>) -> T {
			switch self {
			case .saved(let saved):
					return saved[keyPath: keyPath]
			case .new(let new):
					return new[keyPath: keyPath]
			}
	}
}
