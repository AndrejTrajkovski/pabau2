import Foundation

public struct Document: Codable, Identifiable, Equatable {
	public let id: Int
	public let title: String
	public let format: DocumentExtension
	public let date: Date
}

public enum DocumentExtension: String, Equatable, Codable {
	case bmp
	case csv
	case doc
	case docx
	case jpg
	case numbers
	case pages
	case pdf
	case png
	case tif
	case txt
	case xls
	case xlsx
}
