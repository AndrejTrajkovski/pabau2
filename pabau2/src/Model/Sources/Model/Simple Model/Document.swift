import Foundation

public struct Document: Codable, Identifiable, Equatable {
	public let id: Int
	public let title: String
    public var format: DocumentExtension = .none
	public let date: Date
    public let documentURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "document_title"
        case date = "document_date"
        case documentURL = "normal_size"
        case format
    }
    
    public init(id: Int, title: String, format: DocumentExtension, date: Date, documentURL: String = "" ) {
        self.id = id
        self.title = title
        self.format = format
        self.date = date
        self.documentURL = documentURL
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let strId = try? container.decode(String.self, forKey: .id), let id = Int(strId) {
            self.id = id
        } else {
            self.id = 0
        }
        
        if let sDate = try? container.decode(String.self, forKey: .date) {
            self.date = sDate.toDate("dd/MM/yyyy", region: .local)?.date ?? Date()
        } else {
            self.date = Date()
        }
        
        if let location = try? container.decode(String.self, forKey: .documentURL) {
            let fileType = location.components(separatedBy: ".").last
            if let type = fileType {
                self.format = DocumentExtension(rawValue: type) ?? .none
            }
            self.documentURL = location
        } else {
            self.documentURL = ""
        }
        
        self.title = try container.decode(String.self, forKey: .title)  
    }
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
    case none
    case mp4
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
			Document(id: 15, title: "XLSX", format: .xlsx, date: Date()),
            Document(id: 16, title: "Video", format: .mp4, date: Date())
	]
}
