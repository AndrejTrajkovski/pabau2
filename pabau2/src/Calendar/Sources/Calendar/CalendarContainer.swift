import SwiftUI
import FSCalendarSwiftUI
import ComposableArchitecture
import Model

public typealias CalendarEnvironment = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

public let calendarContainerReducer: Reducer<CalendarState, CalendarAction, CalendarEnvironment> = .combine(
	calendarDatePickerReducer.pullback(
		state: \.selectedDate,
		action: /CalendarAction.datePicker,
		environment: { $0 }
	),
	calTypePickerReducer.pullback(
		state: \.calTypePicker,
		action: /CalendarAction.calTypePicker,
		environment: { $0 })
//	,
//	.init { state, action, _ in
//		switch action {
//		case .datePicker: break
//		case .calTypePicker: break
//	}
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
				}.navigationBarItems(trailing:
					CalendarTypePicker(store:
					self.store.scope(
						state: { $0.calTypePicker },
						action: { .calTypePicker($0)}))
				)//TODO: with xcode 12 use .toolbar modifier
			}
			.navigationViewStyle(StackNavigationViewStyle())
		}
	}

	public init(store: Store<CalendarState, CalendarAction>) {
		self.store = store
	}
}
