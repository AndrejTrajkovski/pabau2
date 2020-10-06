import SwiftUI
import ComposableArchitecture

public struct CalendarSwiftUI: UIViewControllerRepresentable {
	
	let viewStore: ViewStore<CalendarState, CalendarAction>
	
	public func makeUIViewController(context: Context) -> CalendarViewController {
		print("makeUIViewController")
		return CalendarViewController(viewStore)
	}

	public func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
	}
}
