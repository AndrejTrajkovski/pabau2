import SwiftUI
import FSCalendar
import ComposableArchitecture

public struct CalendarDatePicker: View {
	let store: Store<Date, SwiftUICalendarAction>
	@Binding var totalHeight: CGFloat?
	public var body: some View {
		WithViewStore(store) { viewStore in
			SwiftUICalendar.init(viewStore.state,
													 self.$totalHeight,
													 .week) {
														viewStore.send(.selectedDate($0))
			}
		}
	}
	
	public init(
		store: Store<Date, SwiftUICalendarAction>,
		totalHeight: Binding<CGFloat?>) {
		self.store = store
		self._totalHeight = totalHeight
	}
}

public enum SwiftUICalendarAction: Equatable {
	case selectedDate(Date)
}

public let swiftUICalendarReducer: Reducer<Date, SwiftUICalendarAction, Any> = Reducer.init {
	state, action, env in
	switch action {
	case .selectedDate(let date):
		state = date
	}
	return .none
}

struct SwiftUICalendar: UIViewRepresentable {
	public typealias UIViewType = FSCalendar
	@Binding var totalHeight: CGFloat?
	private let scope: FSCalendarScope
	private let date: Date
	private var onDateChanged: (Date) -> Void

	public init(_ date: Date,
							_ height: Binding<CGFloat?>,
							_ scope: FSCalendarScope,
							_ onDateChanged: @escaping (Date) -> Void) {
		self.scope = scope
		self.date = date
		self._totalHeight = height
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
			self.parent.totalHeight = bounds.size.height
		}
	}
}
