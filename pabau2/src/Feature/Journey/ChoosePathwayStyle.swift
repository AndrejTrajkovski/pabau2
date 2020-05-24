import SwiftUI
import Util

enum ChoosePathwayStyle {
	case blue
	case white
	var bgColor: Color {
		switch self {
		case .blue:
			return .gray249
		case .white:
			return .white
		}
	}

	var btnColor: Color {
		switch self {
		case .blue:
			return .blue2
		case .white:
			return .white
		}
	}
}
