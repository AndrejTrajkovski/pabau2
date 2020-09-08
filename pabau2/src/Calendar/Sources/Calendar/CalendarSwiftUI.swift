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
		return CalendarViewController()
	}

	public func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
	}
}
