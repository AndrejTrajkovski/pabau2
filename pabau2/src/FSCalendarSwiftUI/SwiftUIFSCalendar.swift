import SwiftUI
import FSCalendar

public struct SwiftUICalendar: UIViewRepresentable {
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
