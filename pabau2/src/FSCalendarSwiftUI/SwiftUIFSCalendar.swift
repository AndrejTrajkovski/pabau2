import SwiftUI
import FSCalendar

public struct SwiftUICalendar: UIViewRepresentable {

	public typealias UIViewType = FSCalendar
	public init(_ viewModel: MyCalendarViewModel) {
		self.viewModel = viewModel
		self.scope = viewModel.scope
		self.date = viewModel.date
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
	}
}
