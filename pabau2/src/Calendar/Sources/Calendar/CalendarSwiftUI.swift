import SwiftUI

//let header = [
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1),
//	IntervalInfo(1)
//]

public struct CalendarSwiftUI: UIViewControllerRepresentable {
	
	public init () {}
	
	public func makeUIViewController(context: Context) -> CalendarViewController {
		let dataSource = [
//			header,
			[IntervalInfo(4, "0, 0"), IntervalInfo(4, "0, 1")],
			[IntervalInfo(4, "1, 0"), IntervalInfo(3, "1, 1"), IntervalInfo(1, "1, 2")],
//			[IntervalInfo(1), IntervalInfo(2), IntervalInfo(3)],
//			[IntervalInfo(2), IntervalInfo(3)],
//			[IntervalInfo(4), IntervalInfo(4)],
//			[IntervalInfo(4), IntervalInfo(3), IntervalInfo(1)],
//			[IntervalInfo(1), IntervalInfo(2), IntervalInfo(3)],
//			[IntervalInfo(2), IntervalInfo(3)],
//			[IntervalInfo(4), IntervalInfo(4)],
//			[IntervalInfo(4), IntervalInfo(3), IntervalInfo(1)],
//			[IntervalInfo(1), IntervalInfo(2), IntervalInfo(3)],
//			[IntervalInfo(2), IntervalInfo(3)],
//			[IntervalInfo(4), IntervalInfo(4)],
//			[IntervalInfo(4), IntervalInfo(3), IntervalInfo(1)],
//			[IntervalInfo(1), IntervalInfo(2), IntervalInfo(3)],
//			[IntervalInfo(2), IntervalInfo(3)]
		]
		return CalendarViewController.init(dataSource: dataSource)
	}

	public func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
	}
}
