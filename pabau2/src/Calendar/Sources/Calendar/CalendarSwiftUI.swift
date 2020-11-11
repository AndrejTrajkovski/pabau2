import SwiftUI
import ComposableArchitecture
import JZCalendarWeekView
import Model

public struct CalendarWrapper: View {
	let store: Store<CalendarState, CalendarAction>
	
	public var body: some View {
		WithViewStore(store) { viewStore -> AnyView in
			switch viewStore.state.appointments {
			case .week:
				return AnyView(CalendarWeekSwiftUI(store: store.scope(state: { $0 },
																	  action: { .week($0) }
				)))
			case .employee:
				return AnyView(employeeCalendarView)
			case .room:
				return AnyView(roomCalendarView)
			}
		}
	}

	typealias EmployeeCalView = IfLetStore<CalendarSectionViewState<JZAppointmentEvent, Employee>, SubsectionCalendarAction<Employee>, _ConditionalContent<CalendarSwiftUI<JZAppointmentEvent, Employee>, EmptyView>>
	typealias RoomCalView = IfLetStore<CalendarSectionViewState<JZAppointmentEvent, Room>, SubsectionCalendarAction<Room>,
											_ConditionalContent<CalendarSwiftUI<JZAppointmentEvent, Room>, EmptyView>>
	
	var employeeCalendarView: EmployeeCalView {
		let ifLetStore = IfLetStore(store.scope(
										state: { $0.employeeSectionState },
										action: { .employee($0) }),
									then: CalendarSwiftUI<JZAppointmentEvent, Employee>.init(store:), else: EmptyView())
		return ifLetStore
	}
	
	var roomCalendarView: RoomCalView {
		let ifLetStore = IfLetStore(store.scope(
										state: { $0.roomSectionState },
										action: { .room($0) }),
									then: CalendarSwiftUI<JZAppointmentEvent, Room>.init(store:), else: EmptyView())
		return ifLetStore
	}
}

struct CalendarSwiftUI<Event: JZBaseEvent, Section: Identifiable & Equatable>: UIViewControllerRepresentable {
	let store: Store<CalendarSectionViewState<Event, Section>, SubsectionCalendarAction<Section>>
	public func makeUIViewController(context: Context) -> SectionCalendarViewController<Event, Section> {
		print("makeUIViewController")
		return SectionCalendarViewController<Event, Section>(ViewStore(store))
	}

	public func updateUIViewController(_ uiViewController: SectionCalendarViewController<Event, Section>, context: Context) {
	}
}

struct CalendarWeekSwiftUI: UIViewControllerRepresentable {
	let store: Store<CalendarState, CalendarWeekViewAction>

	public func makeUIViewController(context: Context) -> CalendarWeekViewController {
		print("makeUIViewController")
		return CalendarWeekViewController(ViewStore(store))
	}
	public func updateUIViewController(_ uiViewController: CalendarWeekViewController, context: Context) {
	}
}
