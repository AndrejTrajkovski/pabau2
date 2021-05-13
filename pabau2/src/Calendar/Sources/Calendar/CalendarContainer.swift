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
	FiltersReducer<Employee>().reducer.pullback(
		state: \CalendarState.employeeFilters,
		action: /CalendarAction.employeeFilters,
		environment: { $0 }),
	FiltersReducer<Room>().reducer.pullback(
		state: \CalendarState.roomFilters,
		action: /CalendarAction.roomFilters,
		environment: { $0 }),
	calendarReducer.pullback(
		state: \.self,
		action: /.self,
		environment: { $0 }
	),
	.init { state, action, env in
        print("\(action)")
		switch action {
        
		case .gotCalendarResponse(let result):
            switch result {
            case .success(let calendarResponse):
                let employees = state.employees.mapValues {
                    $0.elements
                }.flatMap(\.value)
                
                let chosenEmployeesIds = state.chosenEmployeesIds
                    .compactMap { $0.value }
                    .flatMap { $0 }
                    .removingDuplicates()
                let filteredEmployees = employees.filter { chosenEmployeesIds.contains($0.id) }
                
                let shifts = calendarResponse.rota.compactMap { $0.value }.flatMap { $0.shift }
                let calendarShifts = Shift.convertToCalendar(employees: filteredEmployees, shifts: shifts)
                state.shifts = calendarShifts.mapValues {
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
			
			return .none
//			return env.journeyAPI.getCalendar(
//                startDate: startDate,
//                endDate: endDate,
//                locationIds: state.chosenLocationsIds,
//                employeesIds: employeesIds,
//                roomIds: []
//            )
//			.receive(on: DispatchQueue.main)
//			.catchToEffect()
//			.map(CalendarAction.gotCalendarResponse)
//			.eraseToEffect()
		case .calTypePicker(.onSelect(let calType)):
            state.switchTo(calType: calType)
			return .none
		
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
			//- TODO Iurii
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
		default: break
		}
		return .none
	}
)

public let calendarReducer: Reducer<CalendarState, CalendarAction, CalendarEnvironment> = .combine(
	appDetailsReducer.optional().pullback(
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

struct CalTopBar: View {
	let store: Store<CalendarState, CalendarAction>
	@ObservedObject var viewStore: ViewStore<CalendarState, CalendarAction>
	
	init(store: Store<CalendarState, CalendarAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				addButtons
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
	
	var addButtons: some View {
		HStack {
			PlusButton {
				withAnimation(Animation.easeIn(duration: 0.5)) {
					self.viewStore.send(.addAppointmentTap)
				}
			}
			PlusButton {
				self.viewStore.send(.onAddShift)
			}
		}
	}
}
