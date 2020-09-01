import SwiftUI

let header = [
	0: IntervalInfo(1),
	1: IntervalInfo(1),
	2: IntervalInfo(1),
	3: IntervalInfo(1),
	4: IntervalInfo(1),
	5: IntervalInfo(1),
	6: IntervalInfo(1),
	7: IntervalInfo(1),
	8: IntervalInfo(1),
	9: IntervalInfo(1),
	10: IntervalInfo(1),
	11: IntervalInfo(1),
	12: IntervalInfo(1),
	13: IntervalInfo(1),
	14: IntervalInfo(1),
	15: IntervalInfo(1),
	16: IntervalInfo(1),
	17: IntervalInfo(1),
	18: IntervalInfo(1),
	19: IntervalInfo(1),
	20: IntervalInfo(1),
	21: IntervalInfo(1),
	22: IntervalInfo(1),
	23: IntervalInfo(1)
]

public struct CalendarSwiftUI: UIViewControllerRepresentable {
	
	public init () {}
	
	public func makeUIViewController(context: Context) -> CalendarViewController {
		let dataSource = [
			0: header,
			1: [0: IntervalInfo(4), 1: IntervalInfo(4)],
			2: [0: IntervalInfo(4), 1: IntervalInfo(3), 2: IntervalInfo(1)],
			3: [0: IntervalInfo(1), 1: IntervalInfo(2), 2: IntervalInfo(3)],
			4: [0: IntervalInfo(2), 1: IntervalInfo(3)],
			5: [0: IntervalInfo(4), 1: IntervalInfo(4)],
			6: [0: IntervalInfo(4), 1: IntervalInfo(3), 2: IntervalInfo(1)],
			7: [0: IntervalInfo(1), 1: IntervalInfo(2), 2: IntervalInfo(3)],
			8: [0: IntervalInfo(2), 1: IntervalInfo(3)],
			9: [0: IntervalInfo(4), 1: IntervalInfo(4)],
			10: [0: IntervalInfo(4), 1: IntervalInfo(3), 2: IntervalInfo(1)],
			11: [0: IntervalInfo(1), 1: IntervalInfo(2), 2: IntervalInfo(3)],
			12: [0: IntervalInfo(2), 1: IntervalInfo(3)],
			13: [0: IntervalInfo(4), 1: IntervalInfo(4)],
			14: [0: IntervalInfo(4), 1: IntervalInfo(3), 2: IntervalInfo(1)],
			15: [0: IntervalInfo(1), 1: IntervalInfo(2), 2: IntervalInfo(3)],
			16: [0: IntervalInfo(2), 1: IntervalInfo(3)]
		]
		return CalendarViewController.init(dataSource: dataSource)
	}

	public func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
	}
}
