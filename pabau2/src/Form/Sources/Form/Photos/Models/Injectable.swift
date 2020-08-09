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

extension Injectable {
	public static func injectables() -> [Injectable] {
		return [
			Injectable(id: 0, color: Color(hex: "0168DA"), title: "Artefill", increment: 0.25),
			Injectable(id: 4, color: Color(hex: "B4B5C8"), title: "Mupirocin (Bactroban Ointment)", increment: 0.25),
			Injectable(id: 5, color: Color(hex: "B4B5C8"), title: "Maxalt (Rizatriptan Benzoate)", increment: 0.25),
			Injectable(id: 6, color: Color(hex: "B4B5C8"), title: "MenHibrix", increment: 0.25),
			Injectable(id: 7, color: Color(hex: "A1A1FF"), title: "Methyldopa (Aldomet)", increment: 0.25),
			Injectable(id: 8, color: Color(hex: "A1A1FF"), title: "Botox", increment: 0.25),
			Injectable(id: 9, color: Color(hex: "006400"), title: "Morphone sulfate (Morphine Sulfate Tablets)", increment: 0.25),
			Injectable(id: 10, color: Color(hex: "006400"), title: "Morphine Sulfate Extended-Release ", increment: 0.25),
			Injectable(id: 11, color: Color(hex: "006400"), title: "Metronidazole (Noritate)", increment: 0.25)
		]
	}
}
