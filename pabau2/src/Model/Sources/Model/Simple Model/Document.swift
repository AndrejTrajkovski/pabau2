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

extension Document {
	static let mockDocs =
		[
			Document(id: 1, title: "Ticket", format: .txt, date: Date()),
			Document(id: 3, title: "Some bmp file", format: .bmp, date: Date()),
			Document(id: 4, title: "Excel List", format: .csv, date: Date()),
			Document(id: 5, title: "Medical History", format: .doc, date: Date()),
			Document(id: 6, title: "Homework", format: .docx, date: Date()),
			Document(id: 7, title: "Drivers License", format: .jpg, date: Date()),
			Document(id: 8, title: "List", format: .numbers, date: Date()),
			Document(id: 9, title: "Blah Blah", format: .pages, date: Date()),
			Document(id: 10, title: "CV", format: .pdf, date: Date()),
			Document(id: 11, title: "Client Passport", format: .png, date: Date()),
			Document(id: 12, title: "Tif file", format: .tif, date: Date()),
			Document(id: 13, title: "Notes", format: .txt, date: Date()),
			Document(id: 14, title: "XLS", format: .xls, date: Date()),
			Document(id: 15, title: "XLSX", format: .xlsx, date: Date())
	]
}
