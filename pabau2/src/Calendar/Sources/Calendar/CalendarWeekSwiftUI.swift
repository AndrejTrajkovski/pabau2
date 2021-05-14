import SwiftUI
import ComposableArchitecture
import Model

public struct CalendarWeekSwiftUI: UIViewControllerRepresentable {
	
	public init(store: Store<CalendarWeekViewState, CalendarWeekViewAction>) {
		self.store = store
	}
	
	let store: Store<CalendarWeekViewState, CalendarWeekViewAction>

	public func makeUIViewController(context: Context) -> CalendarWeekViewController {
		print("makeUIViewController")
		return CalendarWeekViewController(ViewStore(store))
	}
	public func updateUIViewController(_ uiViewController: CalendarWeekViewController, context: Context) {
	}
}
