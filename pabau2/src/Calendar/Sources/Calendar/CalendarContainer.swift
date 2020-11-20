import SwiftUI
import FSCalendarSwiftUI
import ComposableArchitecture
import Model
import Util
import SwiftDate

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
	calendarWeekViewReducer.optional.pullback(
		state: \CalendarState.week,
		action: /CalendarAction.week,
		environment: { $0 }),
	AppointmentsByReducer<Employee>().reducer.optional.pullback(
		state: \CalendarState.employeeSectionState,
		action: /CalendarAction.employee,
		environment: { $0 }),
	AppointmentsByReducer<Room>().reducer.optional.pullback(
		state: \CalendarState.roomSectionState,
		action: /CalendarAction.room,
		environment: { $0 }),
	appDetailsReducer.optional.pullback(
		state: \CalendarState.appDetails,
		action: /CalendarAction.appDetails,
		environment: { $0 }),
	.init { state, action, _ in
		switch action {
		case .datePicker: break
		case .calTypePicker(.onSelect(let calTypeId)):
			state.switchTo(id: calTypeId)
		case .onAppDetailsDismiss:
			state.appDetails = nil
		case .calTypePicker(.toggleDropdown): break
		case .addShift: break
		case .toggleFilters: break
		case .room:
			break
		case .week:
			break
		case .employee:
			break
		case .appDetails(.close):
			state.appDetails = nil
		case .employee(.addAppointment(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employee = state.employees[location]?[id: subsection]
			employee.map {
				state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate, employee: $0)
			}
		case .room(.addAppointment(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let room = state.rooms[location]?[id: subsection]
			//FIXME: missing room in add appointments screen
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
		case .week(.addAppointment(let startOfDayDate, let startDate,let durationMins)):
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
		case .appDetails(.addService):
			let start = state.appDetails!.app.start_date
			let end = state.appDetails!.app.end_date
			let employee = state.employees.flatMap { $0.value }.first(where: { $0.id == state.appDetails?.app.employeeId })
			state.calendar.appDetails = nil
			employee.map {
				state.addAppointment = AddAppointmentState.init(startDate: start, endDate: end, employee: $0)
			}
		default: break
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
						action: { .datePicker($0)}
					),
					isWeekView: viewStore.state.appointments.calendarType == Appointments.CalendarType.week
				)
				.padding(0)
				CalendarWrapper(store: self.store)
				Spacer()
			}.sheet(isPresented: viewStore.binding(get: { $0.appDetails != nil },
												   send: CalendarAction.onAppDetailsDismiss),
					content: { IfLetStore(store.scope(state: { $0.appDetails },
													  action: { .appDetails($0) }),
										  then: AppointmentDetails.init(store:))
					})
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
