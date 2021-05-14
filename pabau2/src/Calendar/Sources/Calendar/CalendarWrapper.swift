import SwiftUI
import ComposableArchitecture
import Journey
import Model

public struct CalendarWrapper: View {
	let store: Store<CalendarState, CalendarAction>

	public var body: some View {
		WithViewStore(store) { viewStore -> AnyView in
			switch viewStore.state.appointments {
			case .list:
				return AnyView(Text("LIST"))
			case .week:
				return AnyView(
					IfLetStore.init(
						store.scope(
							state: { $0.week },
							action: { .week($0) }
						),
						then: CalendarWeekSwiftUI.init(store:)
					)
				)
			case .employee:
				return AnyView(employeeCalendarView)
			case .room:
				return AnyView(roomCalendarView)
			}
		}
	}

	typealias EmployeeCalView = IfLetStore<CalendarSectionViewState<Employee>, SubsectionCalendarAction<Employee>, _ConditionalContent<CalendarSwiftUI<Employee>, EmptyView>>
	typealias RoomCalView = IfLetStore<CalendarSectionViewState<Room>, SubsectionCalendarAction<Room>,
											_ConditionalContent<CalendarSwiftUI<Room>, EmptyView>>

	var employeeCalendarView: EmployeeCalView {
		let ifLetStore = IfLetStore(
			store.scope(
				state: { $0.employeeSectionState },
				action: { .employee($0) }
			),
			then: CalendarSwiftUI<Employee>.init(store:), else: { EmptyView() }
		)
		return ifLetStore
	}

	var roomCalendarView: RoomCalView {
		let ifLetStore = IfLetStore(store.scope(
										state: { $0.roomSectionState },
										action: { .room($0) }),
									then: CalendarSwiftUI<Room>.init(store:), else: { EmptyView() })
		return ifLetStore
	}
}
