import SwiftUI

public struct CalendarSwiftUI: UIViewControllerRepresentable {
	
	public init () {}
	
	public func makeUIViewController(context: Context) -> CalendarViewController {
		return CalendarViewController()
	}

	public func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
	}
}
