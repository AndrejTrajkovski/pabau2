import SwiftUI
import ComposableArchitecture
import Model
import Filters
import Appointments

struct FiltersWrapper: View {
	let store: Store<CalendarState, CalendarAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			switch viewStore.appointments.calendarType {
			case .list, .employee, .week:
				Filters<Employee>(
					store:
						store.scope(
							state: { $0.employeeFilters },
							action: { .employeeFilters($0) }
						)
				)
			case .room:
                Filters<Room>(
                    store:
                        store.scope(
                            state: { $0.roomFilters },
                            action: { .roomFilters($0) }
                        )
                )
			}
		}
	}
}
