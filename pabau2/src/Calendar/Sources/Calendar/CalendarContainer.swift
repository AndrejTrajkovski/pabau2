import SwiftUI
import FSCalendarSwiftUI
import ComposableArchitecture
import Model
import Util
import SwiftDate
import AddAppointment
import AddBookout
import Combine
import AddShift
import Filters
import Appointments

public typealias CalendarEnvironment = (apiClient: JourneyAPI, userDefaults: UserDefaultsConfig)

public let calendarContainerReducer: Reducer<CalendarContainerState, CalendarAction, CalendarEnvironment> = .combine(
	calendarReducer.pullback(
		state: \.calendar,
		action: /.self,
		environment: { $0 }
	),
	.init { state, action, env in
		switch action {
		case .employee(.addAppointment(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employee = state.calendar.employees[location]?[id: subsection]
			employee.map {
				state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate, employee: $0)
			}
		case .room(.addAppointment(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let room = state.calendar.rooms[location]?[id: subsection]
			//FIXME: missing room in add appointments screen
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
		case .employee(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employees = state.calendar.employees[location] ?? []
			let chosenEmployee = employees[id: subsection]
			state.calendar.addBookout = AddBookoutState(employees: employees,
														chosenEmployee: chosenEmployee?.id,
														start: startDate)
		case .room(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employees = state.calendar.employees[location] ?? []
			state.calendar.addBookout = AddBookoutState(employees: employees,
														chosenEmployee: nil,
														start: startDate)
		case .week(.addAppointment(let startOfDayDate, let startDate, let durationMins)):
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
        case .week(.editAppointment(let appointment)):
            state.addAppointment = AddAppointmentState.init(editingAppointment: appointment, startDate: appointment.start_time, endDate: appointment.end_time)
		case .appDetails(.addService):
			let start = state.calendar.appDetails!.app.start_date
			let end = state.calendar.appDetails!.app.end_date
			let employee = state.calendar.employees.flatMap { $0.value }.first(where: { $0.id == state.calendar.appDetails?.app.employeeId })
			state.calendar.appDetails = nil
			if let emp = employee {
				return Just(CalendarAction.showAddApp(startDate: start, endDate: end, employee: emp))
					.delay(for: 0.1, scheduler: DispatchQueue.main)
					.eraseToEffect()
			} else {
				return .none
			}
		case .showAddApp(let start, let end, let employee):
			state.addAppointment = AddAppointmentState.init(startDate: start, endDate: end, employee: employee)
		default: break
		}
		return .none
	}
)

public let calendarReducer: Reducer<CalendarState, CalendarAction, CalendarEnvironment> = .combine(
	calendarDatePickerReducer.pullback(
		state: \.selectedDate,
		action: /CalendarAction.datePicker,
		environment: { $0 }
	),
	calTypePickerReducer.pullback(
		state: \.calTypePicker,
		action: /CalendarAction.calTypePicker,
		environment: { $0 }),
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
//	addBookoutReducer.optional.pullback(
//		state: \CalendarState.addBookout,
//		action: /CalendarAction.addBookout,
//		environment: { $0 }),
	addShiftOptReducer.pullback(
		state: \CalendarState.addShift,
		action: /CalendarAction.addShift,
		environment: { $0 }),
	FiltersReducer<Employee>().reducer.pullback(
		state: \.employeeFilters,
		action: /CalendarAction.employeeFilters,
		environment: { $0 }),
	FiltersReducer<Room>().reducer.pullback(
		state: \.roomFilters,
		action: /CalendarAction.roomFilters,
		environment: { $0 }),
	.init { state, action, _ in
		switch action {
		case .datePicker: break
		case .calTypePicker(.onSelect(let calType)):
			state.switchTo(calType: calType)
		case .onAppDetailsDismiss:
			state.appDetails = nil
		case .onBookoutDismiss:
			state.addBookout = nil
		case .calTypePicker(.toggleDropdown): break
		case .onAddShift:
			state.addShift = AddShiftState.makeEmpty()
		case .toggleFilters:
			state.isShowingFilters.toggle()
		case .room:
			break
		case .week:
			break
		case .employee:
			break
		case .appDetails(.close):
			state.appDetails = nil
		case .addBookout(.close):
			state.addBookout = nil
		case .changeCalScope:
			state.scope = state.scope == .week ? .month : .week
		default: break
		}
		return .none
	}
)

public struct CalendarContainer: View {
	let store: Store<CalendarState, CalendarAction>

	public var body: some View {
		WithViewStore(store) { viewStore in
			ZStack(alignment: .topTrailing) {
				VStack(spacing: 0) {
					CalTopBar(store: self.store)
					CalendarDatePicker.init(
						store: self.store.scope(
							state: { $0.selectedDate },
							action: { .datePicker($0)}
						),
						isWeekView: viewStore.state.appointments.calendarType == Appointments.CalendarType.week,
						scope: viewStore.scope
					)
					.padding(0)
					CalendarWrapper(store: self.store)
					Spacer()
				}
				if viewStore.state.isShowingFilters {
					FiltersWrapper(store: store)
						.transition(.moveAndFade)
				}
			}
			.fullScreenCover(
                isPresented:
                    Binding(get: { activeSheet(state: viewStore.state) != nil },
                            set: { _ in dismissAction(state: viewStore.state).map(viewStore.send) }
                    ),
                content: {
                    Group {
                        IfLetStore(
                            store.scope(
                                state: { $0.appDetails },
                                action: { .appDetails($0) }),
                                then: AppointmentDetails.init(store:)
                        )
                        IfLetStore(
                            store.scope(
                                state: { $0.addBookout },
                                action: { .addBookout($0) }),
                                then: AddBookout.init(store:)
                        )
                        IfLetStore(
                            store.scope(
                                state: { $0.addShift },
                                action: { .addShift($0) }),
                                then: AddShift.init(store:)
                        )
                    }
                }
			)
		}
	}

	public init(store: Store<CalendarState, CalendarAction>) {
		self.store = store
	}

	enum ActiveSheet {
		case appDetails
		case addBookout
		case addShift
	}

	func activeSheet(state: CalendarState) -> ActiveSheet? {
		if state.addBookout != nil {
			return .addBookout
		} else if state.appDetails != nil {
			return .appDetails
		} else if state.addShift != nil {
			return .addShift
		} else {
			return nil
		}
	}

	func dismissAction(state: CalendarState) -> CalendarAction? {
		if state.addBookout != nil {
			return .onBookoutDismiss
		} else if state.appDetails != nil {
			return .onAppDetailsDismiss
		} else if state.addShift != nil {
			return .onAddShiftDismiss
		} else {
			return nil
		}
	}
}

struct CalTopBar: View {
	let store: Store<CalendarState, CalendarAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 0) {
				ZStack {
					PlusButton {
						viewStore.send(.onAddShift)
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
					HStack {
						Button {
							viewStore.send(.changeCalScope)
						} label: {
							Image("calendar_icon")
								.renderingMode(.template)
								.accentColor(.blue)
						}
						Button(Texts.filters, action: {
							viewStore.send(.toggleFilters)
						})
					}
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
}
