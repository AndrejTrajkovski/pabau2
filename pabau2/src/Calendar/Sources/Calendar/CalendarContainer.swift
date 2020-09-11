import SwiftUI
import FSCalendarSwiftUI
import ComposableArchitecture
import Model

public typealias CalendarEnvironment = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

public let calendarContainerReducer: Reducer<CalendarState, CalendarAction, CalendarEnvironment> = .combine(
	calendarDatePickerReducer.pullback(
		state: \.selectedDate,
		action: /CalendarAction.datePicker,
		environment: { $0 })
)

public struct CalendarContainer: View {
	let store: Store<CalendarState, CalendarAction>
	public var body: some View {
		WithViewStore(store) { viewStore in
			NavigationView {
				VStack(spacing: 0) {
					CalendarDatePicker.init(
						store: self.store.scope(
							state: { $0.selectedDate },
							action: { .datePicker($0)})
					)
						.padding(0)
					CalendarSwiftUI(store: self.store)
					Spacer()
				}.navigationBarTitle("Day", displayMode: .inline)
			}
			.navigationViewStyle(StackNavigationViewStyle())
		}
	}

	public init(store: Store<CalendarState, CalendarAction>) {
		self.store = store
	}
}
