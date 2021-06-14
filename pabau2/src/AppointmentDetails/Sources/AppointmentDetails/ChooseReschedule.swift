//
//  ChooseReschedule.swift
//

import SwiftUI
import ComposableArchitecture

public struct ChooseRescheduleState: Equatable {
    var isRescheduleActive: Bool = false
}

public enum ChooseRescheduleAction {
    case onBackButton
    case onSelectedOkRescheduleCalendar(Date)
    case onReschedule(Date)
}

public struct ChooseReschedule: View {

    public let store: Store<ChooseRescheduleState, ChooseRescheduleAction>
    @ObservedObject var viewStore: ViewStore<ChooseRescheduleState, ChooseRescheduleAction>
    
    public init(store: Store<ChooseRescheduleState, ChooseRescheduleAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ChooseRescheduleDatePicker { date in
                viewStore.send(.onSelectedOkRescheduleCalendar(date))
            } onCancel: {
                viewStore.send(.onBackButton)
            }
            
            Spacer()
        }
        .navigationBarHidden(false)
        .customBackButton(leadingPadding: -10, action: {
            viewStore.send(.onBackButton)
        })
    }
}

struct ChooseRescheduleDatePicker: View {
    @State private var selectedDate = Date()
    
    var onOk: (Date) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Reschedule appointment")
            DatePicker("Reschedule appointment", selection: $selectedDate, in: Date()...)
                .labelsHidden()
                .datePickerStyle(WheelDatePickerStyle())
            Button("OK") {
                onOk(selectedDate)
            }
            Button("Cancel") {
                onCancel()
            }
            
        }
    }
    
}
