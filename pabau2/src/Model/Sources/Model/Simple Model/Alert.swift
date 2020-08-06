import Foundation

public struct Alert: Codable, Identifiable, Equatable {
	public let id: Int
	public let title: String
	public let date: Date
}

extension Alert {
	static let mockAlerts =
	[
		Alert(id: 1, title: """
m Ipsum is simply dummy text of the printing and typesetting
""", date: Date()),
		Alert(id: 1, title: """
industry. Lorem Ipsum has been the industry's standard dummy text
""", date: Date()),
		Alert(id: 1, title: """
ever since the 1500s, when an unknown printer took a galley of type
""", date: Date()),
		Alert(id: 1, title: """
and scrambled it to make a type specimen book. It has survived not
""", date: Date()),
		Alert(id: 1, title: """
only five centuries, but also the leap into electronic typesetting,
""", date: Date()),
		Alert(id: 1, title: """
remaining essentially unchanged. It was popularised in the 1960s with
""", date: Date()),
		Alert(id: 1, title: """
the release of Letraset sheets containing Lorem Ipsum passages, and
""", date: Date()),
		Alert(id: 1, title: """
more recently with desktop publishing software like Aldus PageMaker
including versions of Lorem Ipsum.
""", date: Date()),
		Alert(id: 1, title: "Omg!", date: Date()),
		Alert(id: 1, title: "Omg prelive is down", date: Date()),
	]
}
