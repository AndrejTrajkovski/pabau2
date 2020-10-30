import SwiftUI
import ComposableArchitecture

public struct CalendarWrapper: View {
	let store: Store<CalendarState, CalendarAction>
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			switch viewStore.state.calendarType {
			case .week:
				CalendarWeekSwiftUI(viewStore: viewStore)
			case .employee, .room:
				CalendarSwiftUI(viewStore: viewStore)
			}
		}
	}
}

struct CalendarSwiftUI: UIViewControllerRepresentable {
	let viewStore: ViewStore<CalendarState, CalendarAction>
	public func makeUIViewController(context: Context) -> CalendarViewController {
		print("makeUIViewController")
		return CalendarViewController(viewStore)
	}

	public func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
	}
}

struct CalendarWeekSwiftUI: UIViewControllerRepresentable {
	let viewStore: ViewStore<CalendarState, CalendarAction>
	
	public func makeUIViewController(context: Context) -> CalendarWeekViewController {
		print("makeUIViewController")
		return CalendarWeekViewController(viewStore)
	}

	public func updateUIViewController(_ uiViewController: CalendarWeekViewController, context: Context) {
	}
}
