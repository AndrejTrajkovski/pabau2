import SwiftUI
import FSCalendar

public struct SwiftUICalendar: UIViewRepresentable {
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
		print("makeUIView FSCalendar")
		let calendar = FSCalendar()
		calendar.select(date)
		calendar.delegate = context.coordinator
		return calendar
	}

	public func updateUIView(_ uiView: FSCalendar, context: UIViewRepresentableContext<SwiftUICalendar>) {
		uiView.select(uiView.selectedDate)
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
