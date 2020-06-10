import Model

public enum Photo: Equatable {
	case saved(SavedPhoto)
	case new(NewPhoto)
}
