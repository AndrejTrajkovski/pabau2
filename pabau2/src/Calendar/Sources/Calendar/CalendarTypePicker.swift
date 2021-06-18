import SwiftUI
import ComposableArchitecture
import Appointments
import Util

public struct CalendarTypePickerState: Equatable {
	var isCalendarTypeDropdownShown: Bool
	var appointments: Appointments
}

public enum CalendarTypePickerAction {
	case onSelect(Appointments.CalendarType)
	case toggleDropdown
}

public let calTypePickerReducer: Reducer<CalendarTypePickerState, CalendarTypePickerAction, CalendarEnvironment> = .init { state, action, _ in
	switch action {
	case .onSelect(let calTypeId):
		state.isCalendarTypeDropdownShown = false
	case .toggleDropdown:
		state.isCalendarTypeDropdownShown.toggle()
	}
	return .none
}

struct CalendarTypePicker: View {
	let store: Store<CalendarTypePickerState, CalendarTypePickerAction>
    @ObservedObject var viewStore: ViewStore<CalendarTypePickerState, CalendarTypePickerAction>

    init(store: Store<CalendarTypePickerState, CalendarTypePickerAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        if Constants.isPad {
            popover
        } else {
            actionSheet
        }
    }

    var popover: some View {
        DropdownTitle(
            title: viewStore.state.appointments.calendarType.title(),
            expanded: viewStore.state.isCalendarTypeDropdownShown
        ) {
            viewStore.send(.toggleDropdown)
        }
        .popover(
            isPresented:
                viewStore.binding(
                    get: { $0.isCalendarTypeDropdownShown },
                    send: CalendarTypePickerAction.toggleDropdown
                )
        ) {
            ForEach(Appointments.CalendarType.allCases, id: \.self) { calType in
                DropdownRow(title: calType.title()).onTapGesture {
                    viewStore.send(.onSelect(calType))
                }
                Divider()
            }.background(Color(hex: "F9F9F9"))
        }
    }

    var actionSheet: some View {
        DropdownTitle(
            title: viewStore.state.appointments.calendarType.title(),
            expanded: viewStore.state.isCalendarTypeDropdownShown
        ) {
            viewStore.send(.toggleDropdown)
        }
        .actionSheet(
            isPresented: viewStore.binding(
                get: { $0.isCalendarTypeDropdownShown },
                send: CalendarTypePickerAction.toggleDropdown
            )
        ) {
            ActionSheet(
                title: Text("Please choose"),
                message: nil,
                buttons: [
                    .default(
                        Text(Appointments.CalendarType.employee.title())
                    ) {
                        viewStore.send(.onSelect(.employee))
                    },
                    .default(
                        Text(Appointments.CalendarType.room.title())
                    ) {
                        viewStore.send(.onSelect(.room))
                    },
                    .default(
                        Text(Appointments.CalendarType.week.title())
                    ) {
                        viewStore.send(.onSelect(.week))
                    },
                    .default(
                        Text(Appointments.CalendarType.list.title())
                    ) {
                        viewStore.send(.onSelect(.list))
                    },
                    .cancel()
                ]
            )
        }
    }
}
