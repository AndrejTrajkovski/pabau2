import SwiftUI
import FSCalendar

struct SwiftUICalendar: UIViewRepresentable {
    
    typealias UIViewType = FSCalendar
    init(_ viewModel: MyCalendarViewModel) {
        self.viewModel = viewModel
        self.scope = viewModel.scope
        self.date = viewModel.date
    }
    private var viewModel: MyCalendarViewModel
    private var scope: FSCalendarScope
    private var date: Date
    
    func makeUIView(context: UIViewRepresentableContext<SwiftUICalendar>) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: UIViewRepresentableContext<SwiftUICalendar>) {
        uiView.select(viewModel.date)
        uiView.setScope(viewModel.scope, animated: false)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate {
        var parent: SwiftUICalendar
        
        init(_ parent: SwiftUICalendar) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            self.parent.viewModel.date = date
        }
    }
}
