import SwiftUI
import FSCalendar
import ComposableArchitecture

public struct CalendarDatePicker: View {
	let store: Store<Date, CalendarDatePickerAction>
	@State var totalHeight: CGFloat?
	public var body: some View {
		WithViewStore(store) { viewStore in
			SwiftUICalendar.init(viewStore.state,
													 .week,
													 onHeightChange: { self.totalHeight = $0 },
													 onDateChanged: { viewStore.send(.selectedDate($0))}
			).frame(height: self.totalHeight)
		}
	}
	
	public init(
		store: Store<Date, CalendarDatePickerAction>) {
		self.store = store
	}
}

public enum CalendarDatePickerAction: Equatable {
	case selectedDate(Date)
}

public let calendarDatePickerReducer: Reducer<Date, CalendarDatePickerAction, Any> = Reducer.init { state, action, _ in
	switch action {
	case .selectedDate(let date):
		state = date
	}
	return .none
}

struct SwiftUICalendar: UIViewRepresentable {
	public typealias UIViewType = FSCalendar
	private let scope: FSCalendarScope
	private let date: Date
	let onHeightChange: (CGFloat) -> Void
	private var onDateChanged: (Date) -> Void

	public init(_ date: Date,
							_ scope: FSCalendarScope,
							onHeightChange: @escaping (CGFloat) -> Void,
							onDateChanged: @escaping (Date) -> Void) {
		self.scope = scope
		self.date = date
		self.onHeightChange = onHeightChange
		self.onDateChanged = onDateChanged
	}

	public func makeUIView(context: UIViewRepresentableContext<SwiftUICalendar>) -> FSCalendar {
		let calendar = FSCalendar()
		calendar.select(date)
		calendar.delegate = context.coordinator
		return calendar
	}

	public func updateUIView(_ uiView: FSCalendar, context: UIViewRepresentableContext<SwiftUICalendar>) {
		uiView.select(date)
		uiView.setScope(scope, animated: false)
	}

	public func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	public class Coordinator: NSObject, FSCalendarDelegate {
		var parent: SwiftUICalendar

		init(_ parent: SwiftUICalendar) {
			self.parent = parent
		}

		public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
			self.parent.onDateChanged(date)
		}

		public func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
			self.parent.onHeightChange(bounds.size.height)
		}
	}
}
