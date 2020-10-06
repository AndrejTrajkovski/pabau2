import SwiftUI
import FSCalendarSwiftUI
import ComposableArchitecture
import Model
import Util

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
	,
	.init { state, action, _ in
		switch action {
		case .datePicker: break
		case .calTypePicker: break
		case .addShift: break
		case .toggleFilters: break
		}
		return .none
	}
)

public struct CalendarContainer: View {
	let store: Store<CalendarState, CalendarAction>
	public var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 0) {
				CalTopBar(store: self.store)
				CalendarDatePicker.init(
					store: self.store.scope(
						state: { $0.selectedDate },
						action: { .datePicker($0)})
				)
				.padding(0)
				CalendarSwiftUI(viewStore: viewStore)
				Spacer()
			}
		}
	}

	public init(store: Store<CalendarState, CalendarAction>) {
		self.store = store
	}
}

struct CalTopBar: View {
	let store: Store<CalendarState, CalendarAction>
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				PlusButton {
				}
				//			.padding()
				.padding(.leading, 20)
				.exploding(.leading)
				CalendarTypePicker(store:
									self.store.scope(
										state: { $0.calTypePicker },
										action: { .calTypePicker($0)})
				)
				.padding()
				.exploding(.center)
				Button.init(Texts.filters, action: {
				})
				.padding()
				.padding(.trailing, 20)
				.exploding(.trailing)
			}
			.frame(height: 50)
			.background(Color(hex: "F9F9F9"))
			Divider()
		}
	}
}
