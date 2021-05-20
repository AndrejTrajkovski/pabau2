import ComposableArchitecture
import SwiftUI
import SharedComponents

public let chooseRepeatReducer: Reducer<ChooseRepeatState, ChooseRepeatAction, CalendarEnvironment> = .init { state, action, env in
    switch action {
    case .onBackBtn:
        state.isRepeatActive = false
    case .onRepeat(let interval):
        state.chosenRepeat = interval.map { RepeatOption(interval: $0, date: Date())}
        state.isDatePickerActive = true
    case .onRepeatChangeEndingDate(let date):
        state.chosenRepeat = RepeatOption(interval: RepeatInterval.everyYear, date: Date())
        state.isDatePickerActive = false
    case .onSelectedDate(let date):
        state.chosenRepeat = RepeatOption(interval: RepeatInterval.everyYear, date: Date())
        return Effect(value: ChooseRepeatAction.onBackBtn)
    }
    return .none
}

public enum RepeatInterval: Int, Identifiable, CaseIterable, Equatable {
    public var id: Int { rawValue }
    case everyDay
    case everyWeek
    case everyMonth
    case everyYear
    case custom

    var title: String {
        switch self {
        case .everyDay: return "Every Day"
        case .everyWeek: return "Every Week"
        case .everyMonth: return "Every Month"
        case .everyYear: return "Every Year"
        case .custom: return "Custom"
        }
    }
}

public struct RepeatOption: Equatable {
    var interval: RepeatInterval
    var date: Date
}

public struct ChooseRepeatState: Equatable {
    var chosenRepeat: RepeatOption?
    var isRepeatActive: Bool = false
    var isDatePickerActive: Bool = false
    
    public init() { }
}

public enum ChooseRepeatAction {
    case onBackBtn
    case onRepeat(RepeatInterval?)
    case onSelectedDate(Date)
    case onRepeatChangeEndingDate(RepeatOption)
}

public struct ChooseRepeat: View {

    public let store: Store<ChooseRepeatState, ChooseRepeatAction>
    @ObservedObject var viewStore: ViewStore<ChooseRepeatState, ChooseRepeatAction>
    
    @State var showsPicker = false
    @State private var selectedDate = Date()

    public init(store: Store<ChooseRepeatState, ChooseRepeatAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack() {
            List {
                ForEach(RepeatInterval.allCases) { item in
                    TextAndCheckMark(item.title,
                                     item == viewStore.state.chosenRepeat?.interval)
                        .onTapGesture {
                            viewStore.send(.onRepeat(item))
                        }
                }
                TextAndCheckMark("No repeat", viewStore.state.chosenRepeat == nil)
                    .onTapGesture {
                        viewStore.send(.onRepeat(nil))
                    }
            }
            if viewStore.chosenRepeat != nil {
                ChooseRepeatDatePicker { date in
                    viewStore.send(.onSelectedDate(date))
                } onCancel: {
                    
                }

            }
        }
    }
}


struct ChooseRepeatDatePicker: View {
    @State private var selectedDate = Date()
    
    var onOk: (Date) -> ()
    var onCancel: () -> ()
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Ending Date")
            DatePicker("Select latest",
                       selection: $selectedDate,
                       displayedComponents: [.date]
            )
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
            Button("OK") {
                onOk(selectedDate)
            }
            Button("Cancel") {
                
            }
            
        }
    }
    
}
