import SwiftUI
import Util

public enum ListFrameStyle {
	case blue
	case white
	public var bgColor: Color {
		switch self {
		case .blue:
			return .gray249
		case .white:
			return .white
		}
	}

	public var btnColor: Color {
		switch self {
		case .blue:
			return .blue2
		case .white:
			return .white
		}
	}
}
