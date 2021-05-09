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
import JZCalendarWeekView
import CoreDataModel

public typealias CalendarEnvironment = (journeyAPI: JourneyAPI, clientsAPI: ClientsAPI, userDefaults: UserDefaultsConfig, storage: CoreDataModel)

struct CalendarSectionOffsetReducer<Section: Identifiable & Equatable & Named> {
	
	init() {}
	
	public let reducer: Reducer<CalendarSectionViewState<Section>, FiltersAction<Section>, CalendarEnvironment> = .init { state, action, _ in
		
		switch action {
		case .rows(id: let locId, action: .header(.expand(let expand))):
			guard let sectionWidth = state.sectionWidth else { break }
			let sizes = SectionCalendarSizes(totalNumberOfRowsOnPage: state.chosenSubsections().count,
											 pageWidth: CGFloat(sectionWidth))
			if sizes.leftOutRowsOnPage > 0 {
				state.sectionOffsetIndex = nil
			} else {
				state.sectionOffsetIndex = 0
			}
		case .rows(id: let locId, action: .rows(let sectionId, action: .toggle)):
			guard let sectionWidth = state.sectionWidth else { break }
			let sizes = SectionCalendarSizes(totalNumberOfRowsOnPage: state.chosenSubsections().count,
											 pageWidth: CGFloat(sectionWidth))
			if sizes.leftOutRowsOnPage > 0 {
				state.sectionOffsetIndex = nil
			} else {
				state.sectionOffsetIndex = 0
			}
		default:
			break
		}
		
		return .none
	}
}

public let calendarContainerReducer: Reducer<CalendarContainerState, CalendarAction, CalendarEnvironment> = .combine(
	calTypePickerReducer.pullback(
		state: \.calTypePicker,
		action: /CalendarAction.calTypePicker,
		environment: { $0 }),
	calendarWeekViewReducer.optional().pullback(
		state: \CalendarContainerState.week,
		action: /CalendarAction.week,
		environment: { $0 }),
	AppointmentsByReducer<Employee>().reducer.optional().pullback(
		state: \CalendarContainerState.employeeSectionState,
		action: /CalendarAction.employee,
		environment: { $0 }),
	AppointmentsByReducer<Room>().reducer.optional().pullback(
		state: \CalendarContainerState.roomSectionState,
		action: /CalendarAction.room,
		environment: { $0 }),
	FiltersReducer<Employee>().reducer.pullback(
		state: \.employeeFilters,
		action: /CalendarAction.employeeFilters,
		environment: { $0 }),
	FiltersReducer<Room>().reducer.pullback(
		state: \.roomFilters,
		action: /CalendarAction.roomFilters,
		environment: { $0 }),
	CalendarSectionOffsetReducer<Employee>().reducer.optional().pullback(
		state: \CalendarContainerState.employeeSectionState,
		action: /CalendarAction.employeeFilters,
		environment: { $0 }),
	CalendarSectionOffsetReducer<Room>().reducer.optional().pullback(
		state: \CalendarContainerState.roomSectionState,
		action: /CalendarAction.roomFilters,
		environment: { $0 }),
	calendarReducer.pullback(
		state: \.calendar,
		action: /.self,
		environment: { $0 }
	),
	.init { state, action, env in
        print("\(action)")
		switch action {
        case .gotLocationsResponse(let result):
            switch result {
            case .success(let locations):
                state.calendar.locations = .init(locations)
                
                return env.journeyAPI.getEmployees()
                    .receive(on: DispatchQueue.main)
                    .catchToEffect()
                    .map(CalendarAction.gotEmployeeResponse)
                    .eraseToEffect()
            case .failure(let error):
                break
            }
        case .gotEmployeeResponse(let result):
            switch result {
            case .success(let employees):
                state.calendar.employees = [:]
                state.calendar.locations.forEach { location in
                    state.calendar.employees[location.id] = IdentifiedArrayOf<Employee>.init([])
                }
                state.calendar.employees.keys.forEach { key in
                    employees.forEach { employee in
                        if employee.locations.contains(key) {
                            state.calendar.employees[key]?.append(employee)
                        }
                    }
                }
                
            case .failure(let error):
                break
            }
		case .gotCalendarResponse(let result):
            switch result {
            case .success(let calendarResponse):
                let employees = state.calendar.employees.mapValues {
                    $0.elements
                }.flatMap(\.value)
                
                let chosenEmployeesIds = state.calendar.chosenEmployeesIds
                    .compactMap { $0.value }
                    .flatMap { $0 }
                    .removingDuplicates()
                let filteredEmployees = employees.filter { chosenEmployeesIds.contains($0.id) }
                
                let shifts = calendarResponse.rota.compactMap { $0.value }.flatMap { $0.shift }
                let calendarShifts = Shift.convertToCalendar(employees: filteredEmployees, shifts: shifts)
                state.calendar.shifts = calendarShifts.mapValues {
                    $0.mapValues {
                        $0.mapValues {
                            let jzshifts = $0.map { JZShift.init(shift: $0)}
                            return [JZShift].init(jzshifts)
                        }
                    }
                }
                print(calendarResponse.appointments, "<---- appointments")
                print(filteredEmployees)
                state.appointments.refresh(
                    events: calendarResponse.appointments,
                    locationsIds: state.chosenLocationsIds,
                    employees: filteredEmployees,
                    rooms: []
                )
            case .failure(let error):
                break
            }
		case .datePicker(.selectedDate(let date)):
			state.selectedDate = date
			
            let startDate = date
            var endDate = date

            if state.appointments.calendarType == .week {
                endDate = Calendar.current.date(byAdding: .day, value: 7, to: endDate) ?? endDate
            }
            let employeesIds = state.selectedEmployeesIds().removingDuplicates()
			
			return env.journeyAPI.getCalendar(
                startDate: startDate,
                endDate: endDate,
                locationIds: state.chosenLocationsIds,
                employeesIds: employeesIds,
                roomIds: []
            )
			.receive(on: DispatchQueue.main)
			.catchToEffect()
			.map(CalendarAction.gotCalendarResponse)
			.eraseToEffect()
		case .calTypePicker(.onSelect(let calType)):
            state.switchTo(calType: calType)
            return Effect(value: CalendarAction.datePicker(.selectedDate(Date())))
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
		//- TODO Iurii
		case .employee(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employees = state.calendar.employees[location] ?? []
			let chosenEmployee = employees[id: subsection]
            state.calendar.addBookoutState = AddBookoutState(
                employees: employees,
                chosenEmployee: chosenEmployee?.id,
                start: startDate
            )
		//- TODO Iurii
		case .room(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (date, location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employees = state.calendar.employees[location] ?? []
			state.calendar.addBookoutState = AddBookoutState(employees: employees,
															 chosenEmployee: nil,
															 start: startDate)
		//- TODO Iurii
		case .week(.addAppointment(let startOfDayDate, let startDate, let durationMins)):
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			state.addAppointment = AddAppointmentState.init(startDate: startDate, endDate: endDate)
        case .week(.editAppointment(let appointment)):
            print(appointment)
            state.addAppointment = AddAppointmentState.init(editingAppointment: appointment, startDate: appointment.start_date, endDate: appointment.end_date)
//
//
//                case .week(.editStartTime(let startOfDayDate, let startDate, let eventId, let startingPointStartOfDay)):
//                    let calId = CalendarEvent.ID.init(rawValue: eventId)
//                    var app = state.appointments[startingPointStartOfDay]?.remove(id: calId)
//                    app?.update(start: startDate)
//                    app.map {
//                        if state.appointments[startOfDayDate] == nil {
//                            state.appointments[startOfDayDate] = IdentifiedArrayOf<CalendarEvent>.init()
//                        }
//                        state.appointments[startOfDayDate]!.append($0)
//                    }
//
//

		case .appDetails(.addService):
			//- TODO Iurii
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
			//- TODO Iurii
			state.addAppointment = AddAppointmentState.init(
                startDate: start,
                endDate: end,
                employee: employee
            )
		default: break
		}
		return .none
	}
)

public let calendarReducer: Reducer<CalendarState, CalendarAction, CalendarEnvironment> = .combine(
	appDetailsReducer.optional.pullback(
		state: \CalendarState.appDetails,
		action: /CalendarAction.appDetails,
		environment: { $0 }),
	addBookoutOptReducer.pullback(
		state: \CalendarState.addBookoutState,
		action: /CalendarAction.addBookoutAction,
		environment: { $0 }),
	addShiftOptReducer.pullback(
		state: \CalendarState.addShift,
		action: /CalendarAction.addShift,
		environment: { $0 }),
	.init { state, action, _ in
		switch action {
		case .datePicker: break
		case .calTypePicker: break
		case .onAppDetailsDismiss:
			state.appDetails = nil
		case .onBookoutDismiss:
			state.addBookoutState = nil
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
		case .addBookoutAction(.close):
			state.addBookoutState = nil
		case .changeCalScope:
			state.scope = state.scope == .week ? .month : .week
		default: break
		}
		return .none
	}
)

public struct CalendarContainer: View {
	let store: Store<CalendarContainerState, CalendarAction>

	public var body: some View {
		WithViewStore(store) { viewStore in
			ZStack(alignment: .topTrailing) {
				VStack(spacing: 0) {
					CalTopBar(store: store.scope(state: { $0 }))
					CalendarDatePicker.init(
						store: self.store.scope(
							state: { $0.selectedDate },
							action: { .datePicker($0)}
						),
						isWeekView: viewStore.state.appointments.calendarType == CalAppointments.CalendarType.week,
						scope: viewStore.calendar.scope
					)
					.padding(0)
					CalendarWrapper(store: self.store)
					Spacer()
                }
				if viewStore.state.calendar.isShowingFilters {
					FiltersWrapper(store: store)
                        .transition(.moveAndFade)
                        .onDisappear {
                            viewStore.send(
                                .datePicker(
                                    .selectedDate(
                                        viewStore.state.selectedDate
                                    )
                                )
                            )
                        }
				}
			}
			.fullScreenCover(
                isPresented:
					Binding(
                        get: { activeSheet(state: viewStore.state.calendar) != nil },
                        set: {
                            _ in dismissAction(state: viewStore.state.calendar).map(viewStore.send)
                            viewStore.send(
                                .datePicker(
                                    .selectedDate(
                                        viewStore.state.selectedDate
                                    )
                                )
                            )
                        }
                    ),
                content: {
                    Group {
                        IfLetStore(
                            store.scope(
								state: { $0.calendar.appDetails },
                                action: { .appDetails($0) }),
                                then: AppointmentDetails.init(store:)
                        )
                        IfLetStore(
                            store.scope(
                                state: { $0.calendar.addBookoutState },
                                action: { .addBookoutAction($0) }),
                                then: AddBookout.init(store:)
                        )
                        IfLetStore(
                            store.scope(
                                state: { $0.calendar.addShift },
                                action: { .addShift($0) }),
                                then: AddShift.init(store:)
                        )
                    }
                }
			)
        }
	}

	public init(store: Store<CalendarContainerState, CalendarAction>) {
		self.store = store
	}

	enum ActiveSheet {
		case appDetails
		case addBookout
		case addShift
	}

	func activeSheet(state: CalendarState) -> ActiveSheet? {
		if state.addBookoutState != nil {
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
		if state.addBookoutState != nil {
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
	let store: Store<CalendarContainerState, CalendarAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 0) {
				ZStack {
					PlusButton {
						viewStore.send(.onAddShift)
					}
					.padding(.leading, 20)
					.exploding(.leading)
                    CalendarTypePicker(
                        store:
                            self.store.scope(
                                state: { $0.calTypePicker },
                                action: { .calTypePicker($0) }
                            )
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
