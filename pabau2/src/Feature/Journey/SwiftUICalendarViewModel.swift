import Foundation
import Combine
import FSCalendar

class MyCalendarViewModel: ObservableObject {
    
    @Published var scope: FSCalendarScope
    @Published var date: Date
    var subscriptions = Set<AnyCancellable>()
    
    init(scope: FSCalendarScope,
         date: Date) {
        self.scope = scope
        self.date = date
    }
}
