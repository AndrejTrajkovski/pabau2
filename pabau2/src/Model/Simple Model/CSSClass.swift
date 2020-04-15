//

import Foundation

public enum CSSClass: String, Codable, Equatable {
	case staticText
	case input_text
	case textarea
	case radio
	case signature
	case checkbox
	case select
	case heading
	case cl_drugs
	case diagram_mini
	
	var metatype: MyCSSValues.Type {
			switch self {
			case .staticText:
					return StaticText.self
			case .checkbox:
					return CheckBox.self
			case .input_text:
				return InputText.self
			case .textarea:
				return TextArea.self
			case .radio:
				return Radio.self
			case .signature:
				return Signature.self
			case .select:
				return Select.self
			case .heading:
				return Heading.self
			case .cl_drugs:
				return ClDrugs.self
			case .diagram_mini:
				return DiagramMini.self
		}
	}
}
