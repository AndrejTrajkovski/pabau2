import Foundation

public struct Note: Identifiable, Codable, Equatable {
	public let id: Int
	public let content: String
	public let date: Date
}

extension Note {
	static let mockNotes =
	[
		Note(id: 1, content: "This is a note", date: Date()),
		Note(id: 2, content: "Patient was hungry", date: Date()),
		Note(id: 3, content: "Patient is alergic to peanuts", date: Date()),
		Note(id: 4, content: "Patient needs a nose job", date: Date()),
		Note(id: 5, content: "Patient has asthma", date: Date()),
		Note(id: 6, content: "This is a dummy note", date: Date()),
	]
}
