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
import AppointmentDetails
import ChooseLocationAndEmployee
import ToastAlert
import FSCalendar

public let calendarContainerReducer: Reducer<CalendarState, CalendarAction, CalendarEnvironment> = .combine(
	calTypePickerReducer.pullback(
		state: \.calTypePicker,
		action: /CalendarAction.calTypePicker,
		environment: { $0 }),
	calendarWeekViewReducer.optional().pullback(
		state: \CalendarState.week,
		action: /CalendarAction.week,
		environment: { $0 }),
	CalendarSectionViewReducer<Employee>().reducer.optional().pullback(
		state: \CalendarState.employeeSectionState,
		action: /CalendarAction.employee,
		environment: { $0 }),
	CalendarSectionViewReducer<Room>().reducer.optional().pullback(
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
				journeyAPI: $0.journeyAPI,
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
        print(action)
		switch action {
		
		case .addEventDelay(let eventType):
			state.isAddEventDropdownShown = false
			return Just(CalendarAction.onAddEvent(eventType))
				.delay(for: 0.1, scheduler: DispatchQueue.main)
				.eraseToEffect()

		case .gotAppointmentsResponse(let result):
			switch result {
			case .success(let calendarResponse):
				state.appsLS = .gotSuccess
				let shifts = calendarResponse.rota.values.flatMap { $0.shift }
				state.shifts = Shift.convertToCalendar(shifts: shifts)
//				state.chosenEmployeesIds = Dictionary.init(grouping: shifts, by: { $0.locationID })
//					.mapValues { $0.map { $0.userID }}
				state.appointments.refresh(
					events: calendarResponse.appointments,
					locationsIds: state.chosenLocationsIds,
					employees: state.selectedEmployeesIds(),
					rooms: state.selectedRoomsIds()
				)
			case .failure(let error):
				print(error)
				state.appsLS = .gotError(error)
			}
		case .datePicker(.selectedDate(let date)):
			
			//+1 hour because the framework alway returns 23:00
			let convertFrameworkDate = date + 1.hours
			state.selectedDate = convertFrameworkDate
			
			return getAppointments()
		case .calTypePicker(.onSelect(let calType)):
			guard calType != state.appointments.calendarType else { return .none }
			state.switchTo(calType: calType)
			return getAppointments()
		case .employee(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let chooseLocAndEmp = ChooseLocationAndEmployeeState(locations: state.locations,
																 employees: state.employees,
																 chosenLocationId: location,
																 chosenEmployeeId: subsection)
			
			state.addBookoutState = AddBookoutState(
				chooseLocAndEmp: chooseLocAndEmp,
				start: startDate
			)
		//- TODO Iurii
		case .room(.addBookout(let startDate, let durationMins, let dropKeys)):
			let (location, subsection) = dropKeys
			let endDate = Calendar.gregorian.date(byAdding: .minute, value: durationMins, to: startDate)!
			let employees = state.employees[location] ?? []
			let chooseLocAndEmp = ChooseLocationAndEmployeeState(locations: state.locations,
																 employees: state.employees,
																 chosenLocationId: location)
			state.addBookoutState = AddBookoutState(
				chooseLocAndEmp: chooseLocAndEmp,
				start: startDate
			)
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
			var returnEffects = [Effect<CalendarAction, Never>.cancel(id: ToastTimerId())]
			if let emp = employee {
				let showAddApp = Just(CalendarAction.showAddApp(startDate: start, endDate: end, employee: emp))
					.delay(for: 0.1, scheduler: DispatchQueue.main)
					.eraseToEffect()
				returnEffects.append(showAddApp)
			}
			return .merge(returnEffects)
        case .appDetails(.onResponseRescheduleAppointment(let response)):
            switch response {
            case .success(let calendarEventId):
                var calendarEvents = state.appointments.flatten().filter { $0.id != calendarEventId }
                
                state.appointments.refresh(
                    events: calendarEvents,
                    locationsIds: state.chosenLocationsIds,
                    employees: state.selectedEmployeesIds(),
                    rooms: state.selectedRoomsIds()
                )
            case .failure:
                break
            }
		case .onAppDetailsDismiss:
			state.appDetails = nil
			return .cancel(id: ToastTimerId())
		case .onBookoutDismiss:
			state.addBookoutState = nil
		case .onAddEvent(.shift):
            let chooseLocAndEmp = ChooseLocationAndEmployeeState(
                locations: state.locations,
                employees: state.employees
            )
			state.addShift = AddShiftState.makeEmpty(chooseLocAndEmp: chooseLocAndEmp)
		case .toggleFilters:
			state.isShowingFilters.toggle()
		case .appDetails(.close):
			state.appDetails = nil
			return .cancel(id: ToastTimerId())
		case .changeCalScope:
			state.scope = state.scope == .week ? .month : .week
		case .datePicker:
			break
		case .calTypePicker(.toggleDropdown):
			if state.calTypePicker.isCalendarTypeDropdownShown {
				state.isAddEventDropdownShown = false
			}
		case .room:
			break
		case .week:
			break
		case .employee:
			break
		case .onAddEvent(.appointment):
			break
		case .appDetails:
			break
		case .onAddShiftDismiss:
			state.addShift = nil
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
		case .gotLocationsResponse(let result):
			state.update(locationsResult: result.map(\.state))
			if state.appsLS == .initial && state.employeesLS == .gotSuccess {
				return getAppointments()
			}
        case .addBookoutAction(.close):
            state.addBookoutState = nil
        case .addBookoutAction(.appointmentCreated(let response)):
            switch response {
            case .success(let calendarEvent):
                state.appsLS = .gotSuccess
                
                var calendarEvents = state.appointments.flatten()
                calendarEvents.append(calendarEvent)
                
                state.appointments.refresh(
                    events: calendarEvents,
                    locationsIds: state.chosenLocationsIds,
                    employees: state.selectedEmployeesIds(),
                    rooms: state.selectedRoomsIds()
                )
                
                return Effect.init(value: CalendarAction.displayBannerMessage(Texts.bookoutSuccessfullyCreated))
                    .eraseToEffect()
                
            case .failure(let error): // Case treated in addAppTapBtnReducer
                break
            }

		case .addBookoutAction(.chooseLocAndEmp(.chooseLocation(.gotLocationsResponse(let result)))),
			 .addShift(.chooseLocAndEmp(.chooseLocation(.gotLocationsResponse(let result)))):
			state.update(locationsResult: result.map(\.state))
		case .addBookoutAction(
				.chooseLocAndEmp(
					.chooseEmployee(
						.gotEmployeeResponse(let result)))),
			 .addShift(
				.chooseLocAndEmp(
					.chooseEmployee(
						.gotEmployeeResponse(let result)))):
			state.update(employeesResult: result.map(\.state))
		case .onAddEvent(.bookout):
			let chooseLocAndEmp = ChooseLocationAndEmployeeState(locations: state.locations,
																 employees: state.employees)
			state.addBookoutState = AddBookoutState(chooseLocAndEmp: chooseLocAndEmp,
													start: state.selectedDate)
		case .addEventDropdownToggle(let value):
			state.isCalendarTypeDropdownShown = false
			state.isAddEventDropdownShown = value
		case .list(.locationSection(id: let locId, action: .rows(id: let appId, action: .select))):
			guard let app = state.listContainer?.appointments.appointments[locId]?.values.flatMap({ $0.elements }).first(where: { $0.id == appId }) else { break }
			state.appDetails = AppDetailsState(app: app)

		case .roomFilters(.rows(id: let id, action: let action)):
			break
		case .roomFilters(.reload):
			break
		case .employeeFilters(.rows(id: let id, action: let action)):
			break
		case .employeeFilters(.reload):
			break
		case .addBookoutAction:
			break
        case .addShift(let shiftAction):
            switch shiftAction {
            case .shiftCreated(let response):
                switch response {
                case .success(let shift):
                    state.appsLS = .gotSuccess
                    
                    let jzShiftsArr = state.shifts.values.flatMap { $0.values.flatMap { $0.values.flatMap { $0 }}}
                    var shiftsArr = jzShiftsArr.map { $0.shift }
                    shiftsArr.append(shift)
                    state.shifts = Shift.convertToCalendar(shifts: shiftsArr)
                    
                    state.appointments.refresh(
                        events: state.appointments.flatten(),
                        locationsIds: state.chosenLocationsIds,
                        employees: state.selectedEmployeesIds(),
                        rooms: state.selectedRoomsIds()
                    )
                    
                    return Effect.init(value: CalendarAction.displayBannerMessage(Texts.shiftSuccessfullyCreated))
                        .eraseToEffect()
                    
                case .failure(let error):
                    break
                }
                break
            default:
                break
            }
			break
		case .employeeFilters(.gotLocationsResponse(_)):
			break
		case .roomFilters(.gotLocationsResponse(_)):
			break
		case .list(.selectedFilter(_)):
			break
		case .list(.searchedText(_)):
			break
        case .refresh:
            return getAppointments()
        case .appointmentCreatedResponse(let response):
            switch response {
            case .success(let calendarEvent):
                state.appsLS = .gotSuccess
                
                var calendarEvents = state.appointments.flatten()
                calendarEvents.append(calendarEvent)
                
                state.appointments.refresh(
                    events: calendarEvents,
                    locationsIds: state.chosenLocationsIds,
                    employees: state.selectedEmployeesIds(),
                    rooms: state.selectedRoomsIds()
                )
                
                return Effect.init(value: CalendarAction.displayBannerMessage(Texts.appointmentSuccessfullyCreated))
                    .eraseToEffect()
                
            case .failure(let error): // Case treated in addAppTapBtnReducer
                break
            }
        case .displayBannerMessage(let message):
            state.toast = ToastState(mode: .banner(.slide),
                                     type: .regular,
                                     title: message)
            
            return Effect.timer(id: ToastTimerId(), every: 5, on: DispatchQueue.main)
                .map { _ in CalendarAction.dismissToast }
            
        case .dismissToast:
            state.toast = nil
            return .cancel(id: ToastTimerId())
        }
		return .none
	}
)

public struct CalendarContainer: View {
	let store: Store<CalendarState, CalendarAction>
    
    public init(store: Store<CalendarState, CalendarAction>) {
        self.store = store
    }
    
    struct ViewState: Equatable {
        var appointments: Appointments
        var selectedDate: Date
        var isShowingFilters: Bool
        var scope: FSCalendarScope
        var addBookoutState: AddBookoutState?
        var appDetails: AppDetailsState?
        var addShift: AddShiftState?
        
        init(state: CalendarState) {
            self.appointments =  state.appointments
            self.selectedDate = state.selectedDate
            self.isShowingFilters = state.isShowingFilters
            self.scope = state.scope
            self.addBookoutState = state.addBookoutState
            self.appDetails = state.appDetails
            self.addShift = state.addShift
        }
    }

	public var body: some View {
        WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
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
						.transition(.moveAndFade).padding(.top, Constants.statusBarHeight)
				}
			}
			.ignoresSafeArea()
            .toast(store: store.scope(state: \.toast))
			.fullScreenCover(
				isPresented:
					Binding(
						get: { activeSheet(state: viewStore.state) != nil },
						set: {
							_ in dismissAction(state: viewStore.state).map(viewStore.send)
						}
					),
				content: {
					Group {
						IfLetStore(
							store.scope(
								state: { $0.addShift },
								action: { .addShift($0) }),
							then: AddShift.init(store:)
						)
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
					}
				}
			)
		}
	}
    
	enum ActiveSheet {
		case appDetails
		case addBookout
		case addShift
	}

	func activeSheet(state: ViewState) -> ActiveSheet? {
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

	func dismissAction(state: ViewState) -> CalendarAction? {
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
