import SwiftUI
import ComposableArchitecture

public struct CalendarSwiftUI: UIViewControllerRepresentable {
	
	let store: Store<CalendarState, CalendarAction>
	
	public func makeUIViewController(context: Context) -> CalendarViewController {
		return CalendarViewController(ViewStore.init(store))
	}

	public func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
	}
}
