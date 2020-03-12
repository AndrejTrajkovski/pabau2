import SwiftUI
import FSCalendar

public struct SwiftUICalendar: UIViewRepresentable {
	@Binding var totalHeight: CGFloat
	public typealias UIViewType = FSCalendar
	public init(_ viewModel: MyCalendarViewModel,
							_ height: Binding<CGFloat>) {
		self.viewModel = viewModel
		self.scope = viewModel.scope
		self.date = viewModel.date
		self._totalHeight = height
	}
	private var viewModel: MyCalendarViewModel
	private var scope: FSCalendarScope
	private var date: Date

	public func makeUIView(context: UIViewRepresentableContext<SwiftUICalendar>) -> FSCalendar {
		let calendar = FSCalendar()
		calendar.delegate = context.coordinator
		return calendar
	}

	public func updateUIView(_ uiView: FSCalendar, context: UIViewRepresentableContext<SwiftUICalendar>) {
		uiView.select(viewModel.date)
		uiView.setScope(viewModel.scope, animated: false)
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
			self.parent.viewModel.date = date
		}
		public func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
			self.parent.totalHeight = bounds.size.height
			//			calendar.frame = CGRect.init(origin: calendar.frame.origin, size: CGSize.init(width: bounds.size.width, height: 250))
		}
	}
}
