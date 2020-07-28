import SwiftUI

public struct Injectable: Hashable, Identifiable {
	public let id: InjectableId
	let color: Color
	let title: String
	let increment: Double
	var runningIncrement: Double
	init(
		id: InjectableId,
		color: Color,
		title: String,
		increment: Double
	) {
		self.id = id
		self.color = color
		self.title = title
		self.increment = increment
		self.runningIncrement = increment
	}
}
