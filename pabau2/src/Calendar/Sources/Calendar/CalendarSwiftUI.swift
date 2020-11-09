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
				return AnyView(CalendarWeekSwiftUI(viewStore: viewStore))
			case .employee:
				return AnyView(employeeCalendarView)
			case .room:
				return AnyView(roomCalendarView)
			}
		}
	}
	
	typealias EmployeeCalView = IfLetStore<CalendarSectionViewState<JZAppointmentEvent, Employee>, CalendarAction, _ConditionalContent<CalendarSwiftUI<JZAppointmentEvent, Employee>, EmptyView>>
	typealias EmployeeRoomView = IfLetStore<CalendarSectionViewState<JZAppointmentEvent, Room>, CalendarAction,
											_ConditionalContent<CalendarSwiftUI<JZAppointmentEvent, Room>, EmptyView>>
	
	var employeeCalendarView: EmployeeCalView {
		let ifLetStore = IfLetStore(store.scope(state: { $0.employeeSectionState }), then: CalendarSwiftUI<JZAppointmentEvent, Employee>.init(store:), else: EmptyView())
		return ifLetStore
	}
	
	var roomCalendarView: EmployeeRoomView {
		let ifLetStore = IfLetStore(store.scope(state: { $0.roomSectionState }), then: CalendarSwiftUI<JZAppointmentEvent, Room>.init(store:), else: EmptyView())
		return ifLetStore
	}
}

struct CalendarSwiftUI<Event: JZBaseEvent, Section: Identifiable & Equatable>: UIViewControllerRepresentable {
	let store: Store<CalendarSectionViewState<Event, Section>, CalendarAction>
	public func makeUIViewController(context: Context) -> SectionCalendarViewController<Event, Section> {
		print("makeUIViewController")
		return SectionCalendarViewController<Event, Section>(ViewStore(store))
	}
	
	public func updateUIViewController(_ uiViewController: SectionCalendarViewController<Event, Section>, context: Context) {
	}
}

struct CalendarWeekSwiftUI: UIViewControllerRepresentable {
	let viewStore: ViewStore<CalendarState, CalendarAction>
	
	public func makeUIViewController(context: Context) -> CalendarWeekViewController {
		print("makeUIViewController")
		return CalendarWeekViewController(viewStore)
	}
	
	public func updateUIViewController(_ uiViewController: CalendarWeekViewController, context: Context) {
	}
}
