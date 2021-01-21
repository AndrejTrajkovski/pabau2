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
				return AnyView(
					IfLetStore.init(store.scope(state: { $0.week },
												action: { .week($0) }),
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
		let ifLetStore = IfLetStore(store.scope(
										state: { $0.employeeSectionState },
										action: { .employee($0) }),
									then: CalendarSwiftUI<Employee>.init(store:), else: EmptyView())
		return ifLetStore
	}

	var roomCalendarView: RoomCalView {
		let ifLetStore = IfLetStore(store.scope(
										state: { $0.roomSectionState },
										action: { .room($0) }),
									then: CalendarSwiftUI<Room>.init(store:), else: EmptyView())
		return ifLetStore
	}
}

struct CalendarSwiftUI<Section: Identifiable & Equatable>: UIViewControllerRepresentable {
	let store: Store<CalendarSectionViewState<Section>, SubsectionCalendarAction<Section>>
	public func makeUIViewController(context: Context) -> SectionCalendarViewController<Section> {
		print("makeUIViewController")
		return SectionCalendarViewController<Section>(ViewStore(store))
	}

	public func updateUIViewController(_ uiViewController: SectionCalendarViewController<Section>, context: Context) {
	}
}

struct CalendarWeekSwiftUI: UIViewControllerRepresentable {
	let store: Store<CalendarWeekViewState, CalendarWeekViewAction>

	public func makeUIViewController(context: Context) -> CalendarWeekViewController {
		print("makeUIViewController")
		return CalendarWeekViewController(ViewStore(store))
	}
	public func updateUIViewController(_ uiViewController: CalendarWeekViewController, context: Context) {
	}
}
