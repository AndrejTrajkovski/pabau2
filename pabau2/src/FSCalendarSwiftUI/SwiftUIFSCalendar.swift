import SwiftUI
import FSCalendar

public struct SwiftUICalendar: UIViewRepresentable {
	@Binding var totalHeight: CGFloat?
	public typealias UIViewType = FSCalendar
	private var scope: FSCalendarScope
	private var date: Date
	
	public init(_ date: Date,
							_ height: Binding<CGFloat?>,
							_ scope: FSCalendarScope = .week) {
		self.scope = scope
		self.date = date
		self._totalHeight = height
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
			self.parent.date = date
		}
		public func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
			self.parent.totalHeight = bounds.size.height
			//			calendar.frame = CGRect.init(origin: calendar.frame.origin, size: CGSize.init(width: bounds.size.width, height: 250))
		}
	}
}
