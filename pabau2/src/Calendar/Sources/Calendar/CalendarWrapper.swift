import SwiftUI
import ComposableArchitecture
import CalendarList
import Model
import Util
import Appointments
import SharedComponents

public struct CalendarWrapper: View {
    
	let store: Store<CalendarState, CalendarAction>
    @ObservedObject var viewStore: ViewStore<State, CalendarAction>
    
    init(store: Store<CalendarState, CalendarAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: State.init(state:)))
    }
    
    struct State: Equatable {
        let appsLS: LoadingState
        let calType: Appointments.CalendarType
        init(state: CalendarState) {
            self.appsLS = state.appsLS
            self.calType = state.appointments.calendarType
        }
    }
    
    public var body: some View {
        switch self.viewStore.state.appsLS {
        case .gotError(_):
            RawErrorView(description: "Something went wrong when loading appointments. You can try again by picking a date.")
        case .initial:
            Text("Load appointments by choosing a date")
        case .gotSuccess:
            loadedApps
        case .loading:
            LoadingSpinner(title: "Loading appointments...")
        }
	}
    
    var loadedApps: some View {
        switch viewStore.state.calType {
        case .list:
            return AnyView(listContainerView)
        case .week:
            return AnyView(weekView)
        case .employee:
            return AnyView(employeeCalendarView)
        case .room:
            return AnyView(roomCalendarView)
        }
    }
	
	var listContainerView: some View {
        IfLetStore(
            store.scope(
                state: { $0.listContainer },
                action: { .list($0) }
            ),
            then: ListContainerView.init(store:)
        )
	}

	var weekView: some View {
		IfLetStore.init(
			store.scope(
				state: { $0.week },
				action: { .week($0) }
			),
			then: CalendarWeekSwiftUI.init(store:)
		)
	}

	typealias EmployeeCalView = IfLetStore<CalendarSectionViewState<Employee>, SubsectionCalendarAction<Employee>, _ConditionalContent<CalendarSwiftUI<Employee>, EmptyView>>
	typealias RoomCalView = IfLetStore<CalendarSectionViewState<Room>, SubsectionCalendarAction<Room>,
											_ConditionalContent<CalendarSwiftUI<Room>, EmptyView>>

	var employeeCalendarView: some View {
		let ifLetStore = IfLetStore(
			store.scope(
				state: { $0.employeeSectionState },
				action: { .employee($0) }
			),
			then: CalendarSwiftUI<Employee>.init(store:)
		)
		return ifLetStore
	}

	var roomCalendarView: some View {
        let ifLetStore = IfLetStore(
            store.scope(
                state: { $0.roomSectionState },
                action: { .room($0) }
            ),
            then: CalendarSwiftUI<Room>.init(store:)
        )
		return ifLetStore
	}
}
