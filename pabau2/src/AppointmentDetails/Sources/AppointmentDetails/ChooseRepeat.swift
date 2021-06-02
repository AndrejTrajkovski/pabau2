import ComposableArchitecture
import SwiftUI
import SharedComponents

public let chooseRepeatReducer: Reducer<ChooseRepeatState, ChooseRepeatAction, AppDetailsEnvironment> = .init { state, action, env in
    switch action {
    case .onBackBtn:
        break
    case .onChangeInterval(let interval):
        state.chosenRepeat = interval.map { RepeatOption(interval: $0, date: Date())}
    case .onSelectedOkCalendar(let date):
        state.chosenRepeat?.date = date
        return Effect(value: ChooseRepeatAction.onRepeat(state.chosenRepeat!))
    default:
        break
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
    
    var interval: String {
        switch self {
        case .everyDay:
            return "day"
        case .everyWeek:
            return "week"
        case .everyMonth:
            return "month"
        case .everyYear:
            return "year"
        default:
            return ""
        }
    }
}

public struct RepeatOption: Equatable {
    var interval: RepeatInterval
    var date: Date
}

public struct ChooseRepeatState: Equatable {
    var isRepeatActive: Bool = false
    var isRescheduleActive: Bool = false
    var chosenRepeat: RepeatOption?
    
    public init() { }
}

public enum ChooseRepeatAction {
    case onBackBtn
    case onRepeat(RepeatOption)
    case onChangeInterval(RepeatInterval?)
    case onSelectedOkCalendar(Date)
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
        GeometryReader { geo in
            VStack {
                List {
                    ForEach(RepeatInterval.allCases) { item in
                        TextAndCheckMark(item.title,
                                         item == viewStore.state.chosenRepeat?.interval)
                            .onTapGesture {
                                viewStore.send(.onChangeInterval(item))
                            }
                    }
                    TextAndCheckMark("No repeat", viewStore.state.chosenRepeat == nil)
                        .onTapGesture {
                            viewStore.send(.onBackBtn)
                        }
                }.frame(height: 310)
                
                if viewStore.chosenRepeat != nil {
                    Spacer()
                        .frame(height: 40)
                    ChooseRepeatDatePicker { date in
                        viewStore.send(.onSelectedOkCalendar(date))
                    } onCancel: {
                        viewStore.send(.onBackBtn)
                    }
                }
            }
            .navigationBarHidden(false)
            .customBackButton(leadingPadding: -10, action: {
                viewStore.send(.onBackBtn)
            })
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
