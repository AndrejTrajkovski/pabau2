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
import Overture

public let calendarContainerReducer: Reducer<CalendarState, CalendarAction, CalendarEnvironment> = .combine(
	calTypePickerReducer.pullback(
		state: \.calTypePicker,
		action: /CalendarAction.calTypePicker,
		environment: { $0 }),
	calendarWeekViewReducer.optional().pullback(
		state: \CalendarState.week,
		action: /CalendarAction.week,
		environment: { $0 }),
	AppointmentsByReducer<Employee>().reducer.optional().pullback(
		state: \CalendarState.employeeSectionState,
		action: /CalendarAction.employee,
		environment: { $0 }),
	AppointmentsByReducer<Room>().reducer.optional().pullback(
		state: \CalendarState.roomSectionState,
		action: /CalendarAction.room,
		environment: { $0 }),
	FiltersReducer<Employee>(locationsKeyPath: \Employee.locations).reducer.pullback(
		state: \CalendarState.employeeFilters,
		action: /CalendarAction.employeeFilters,
		environment: makeFiltersEnv(calendarEnv:)),
	FiltersReducer<Room>(locationsKeyPath: \Room.locationIds).reducer.pullback(
		state: \CalendarState.roomFilters,
		action: /CalendarAction.roomFilters,
		environment: makeFiltersEnv(calendarEnv:)),
	appDetailsReducer.optional().pullback(
		state: \CalendarState.appDetails,
		action: /CalendarAction.appDetails,
		environment: { $0 }),
	addBookoutOptReducer.pullback(
		state: \CalendarState.addBookoutState,
		action: /CalendarAction.addBookoutAction,
		environment: {
			AddBookoutEnvironment(
				repository: $0.repository,
				userDefaults: $0.userDefaults
			)
		}
	),
	addShiftOptReducer.pullback(
		state: \CalendarState.addShift,
		action: /CalendarAction.addShift,
		environment: { $0 }
	),
	.init { state, action, env in
		
		struct GetAppointmentsCancelID: Hashable { }
		
		func getAppointments() -> Effect<CalendarAction, Never> {
			state.appsLS = .loading
			let params = appointmentsAPIParams(state: state)
			let getCalendar = with(params, env.journeyAPI.getCalendar)
			return getCalendar
			.receive(on: DispatchQueue.main)
			.catchToEffect()
			.map(CalendarAction.gotAppointmentsResponse)
			.eraseToEffect()
			.cancellable(id: GetAppointmentsCancelID(), cancelInFlight: true)
		}
		
		switch action {
        
		case .gotAppointmentsResponse(let result):
			switch result {
			case .success(let calendarResponse):
				
				state.appsLS = .gotSuccess
				let shifts = calendarResponse.rota.values.flatMap { $0.shift }
				state.shifts = Shift.convertToCalendar(shifts: shifts)
				state.appointments.refresh(
					events: calendarResponse.appointments,
					locationsIds: state.chosenLocationsIds,
					employees: state.selectedEmployeesIds(),
					rooms: state.selectedRoomsIds()
				)
			case .failure(let error):
				state.appsLS = .gotError(error)
			}
			
		case .datePicker(.selectedDate(let date)):
			
			state.selectedDate = date
			
			return getAppointments()
			
		case .calTypePicker(.onSelect(let calType)):
			guard calType != state.appointments.calendarType else { return .none }
            state.switchTo(calType: calType)
			return getAppointments()
			
		case .employee(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employees = state.employees[location] ?? []
			let chosenEmployee = employees[id: subsection]
            state.addBookoutState = AddBookoutState(
                employees: employees,
                chosenEmployee: chosenEmployee?.id,
                start: startDate
            )
		//- TODO Iurii
		case .room(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employees = state.employees[location] ?? []
			state.addBookoutState = AddBookoutState(employees: employees,
															 chosenEmployee: nil,
															 start: startDate)
		
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
			
			let start = state.appDetails!.app.start_date
			let end = state.appDetails!.app.end_date
			let employee = state.employees.flatMap { $0.value }.first(where: { $0.id == state.appDetails?.app.employeeId })
			state.appDetails = nil
			if let emp = employee {
				return Just(CalendarAction.showAddApp(startDate: start, endDate: end, employee: emp))
					.delay(for: 0.1, scheduler: DispatchQueue.main)
					.eraseToEffect()
			} else {
				return .none
			}
		case .onAppDetailsDismiss:
			state.appDetails = nil
		case .onBookoutDismiss:
			state.addBookoutState = nil
		case .onAddShift:
			state.addShift = AddShiftState.makeEmpty()
		case .toggleFilters:
			
			state.isShowingFilters.toggle()
			
		case .appDetails(.close):
			state.appDetails = nil
		case .addBookoutAction(.close):
			state.addBookoutState = nil
		case .changeCalScope:
			state.scope = state.scope == .week ? .month : .week
		case .datePicker:
			break
		case .calTypePicker:
			break
		case .room:
			break
		case .week:
			break
		case .employee:
			break
		case .addAppointmentTap:
			break
		case .addShift(_):
			break
		case .appDetails(_):
			break
		case .addBookoutAction(_):
			break
		case .onAddShiftDismiss:
			break
		case .showAddApp(startDate: _, endDate: _, employee: _):
			break
		case .employeeFilters(.onHeaderTap), .roomFilters(.onHeaderTap):
			state.isShowingFilters.toggle()
			guard !state.isShowingFilters else { return .none }
			return getAppointments()
		case .roomFilters(.gotSubsectionResponse(let result)):
			if case .success = result,
			   state.appsLS == .initial,
			   state.locationsLS == .gotSuccess,
			   !state.appointments.calendarType.isEmployeeFilter() {
				//load appointments after login if room is selected
				return getAppointments()
			}
		case .employeeFilters(.gotSubsectionResponse(let result)):
			if case .success(_) = result,
			   state.appsLS == .initial,
			   case .gotSuccess = state.locationsLS,
			   state.appointments.calendarType.isEmployeeFilter() {
				//load appointments after login if employee, week or list is selected
				return getAppointments()
			}
		case .list(_):
			break
		case .gotLocationsResponse(let result):
			switch result {
			case .success(let locations):
				state.locationsLS = .gotSuccess
				state.locations = .init(locations.state)
				state.chosenLocationsIds = Set(locations.state.map(\.id))
				if state.appsLS == .initial && state.employeesLS == .gotSuccess {
					return getAppointments()
				}
			case .failure(let error):
				state.locationsLS = .gotError(error)
			}
		case .roomFilters(.rows(id: let id, action: let action)):
			break
		case .roomFilters(.gotLocationsResponse(_)):
			break
		case .roomFilters(.reload):
			break
		case .employeeFilters(.rows(id: let id, action: let action)):
			break
		case .employeeFilters(.gotLocationsResponse(_)):
			break
		case .employeeFilters(.reload):
			break
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
					CalTopBar(store: store.scope(state: { $0 }))
					CalendarDatePicker(
						store: self.store.scope(
							state: { $0.selectedDate },
							action: { .datePicker($0)}
						),
						isWeekView: viewStore.state.appointments.calendarType == Appointments.CalendarType.week,
						scope: viewStore.scope
					)
					CalendarWrapper(store: self.store)
						.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
				if viewStore.state.isShowingFilters {
					FiltersWrapper(store: store)
                        .transition(.moveAndFade)
                        .onDisappear {
                            
                        }
				}
			}
			.fullScreenCover(
                isPresented:
					Binding(
                        get: { activeSheet(state: viewStore.state) != nil },
                        set: {
                            _ in dismissAction(state: viewStore.state).map(viewStore.send)
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
								state: { $0.appDetails },
                                action: { .appDetails($0) }),
                                then: AppointmentDetails.init(store:)
                        )
                        IfLetStore(
                            store.scope(
                                state: { $0.addBookoutState },
                                action: { .addBookoutAction($0) }),
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
	
	var searchBarButton: some View {
		HStack(spacing: 8.0) {
			Button(action: {
				withAnimation {
//					self.showSearchBar.toggle()
				}
			}, label: {
				Image(systemName: "magnifyingglass")
					.font(.system(size: 20))
					.frame(width: 44, height: 44)
			})
		}
	}
}

extension Shift {
	public static func convertToCalendar(
		shifts: [Shift]
	) -> [Date: [Location.ID: [Employee.Id: [JZShift]]]] {
		
		let jzShifts = shifts.map(JZShift.init(shift:))
		
		let byDate = Dictionary.init(grouping: jzShifts, by: { $0[dynamicMember: \.date] })
		
		return byDate.mapValues { events in
			return Dictionary.init(
				grouping: events,
				by: { $0[dynamicMember: \.locationID] }
			)
			.mapValues { events2 in
				Dictionary.init(
					grouping: events2,
					by: { $0[dynamicMember: \.userID] }
				)
			}
		}
	}
}
