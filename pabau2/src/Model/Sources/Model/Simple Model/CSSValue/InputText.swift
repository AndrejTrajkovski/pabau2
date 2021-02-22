import Foundation
import Overture

public enum InputText: Equatable, Hashable {
	
	static let parsingDF = DateFormatter.formDateField
	
	public init (fldType: String?) {
		if fldType == "date" {
			self = .date(nil)
		} else {
			self = .justText("")
		}
	}
	
	case justText(String?)
	case date(Date?)
	
	mutating func updateWith(medicalResult: MedicalResult) {
		switch self {
		case .justText:
			self = .justText(medicalResult.value)
		case .date:
			print("date2: \(medicalResult.value)")
			self = .date(Self.dateFrom(value: medicalResult.value))
		}
	}
	
	static func dateFrom(value: String?) -> Date? {
		value.flatMap(Self.parsingDF.date(from:))
	}
	
	public var isFulfilled: Bool {
		switch self {
		case .justText(let text):
			return !(text?.isEmpty ?? true)
		case .date(let date):
			return date != nil
		}
	}
	
	func getValue() -> String? {
		switch self {
		case .date(let date):
			return date.map{ Self.parsingDF.string(from: $0) }
		case .justText(let string):
			return string
		}
	}
}
