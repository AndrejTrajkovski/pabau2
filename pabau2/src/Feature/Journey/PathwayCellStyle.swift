import SwiftUI
import Util

enum PathwayCellStyle {
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

	var btnShadowColor: Color {
		switch self {
		case .blue:
			return .bigBtnShadow1
		case .white:
			return .bigBtnShadow2
		}
	}

	var btnShadowBlur: CGFloat {
		switch self {
		case .blue:
			return 4.0
		case .white:
			return 8.0
		}
	}
}
