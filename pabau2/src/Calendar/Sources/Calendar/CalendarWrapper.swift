import SwiftUI
import ComposableArchitecture
import CalendarList
import Model

public struct CalendarWrapper: View {
	let store: Store<CalendarState, CalendarAction>

	public var body: some View {
		WithViewStore(store) { viewStore -> AnyView in
			switch viewStore.state.appointments {
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
	}
	
	var listContainerView: some View {
		IfLetStore(
			store.scope(state: { $0.listContainer },
						action: { .list($0) }),
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
