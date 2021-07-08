import ComposableArchitecture
import SwiftDate
import Model
import AddBookout
import AppointmentDetails
import ChooseLocationAndEmployee

public struct CalendarWeekViewState: Equatable {
	var appointments: [Date: IdentifiedArrayOf<CalendarEvent>]
	var selectedDate: Date
	var addBookout: AddBookoutState?
	var appDetails: AppDetailsState?
	let locations: IdentifiedArrayOf<Location>
	let employees: [Location.ID: IdentifiedArrayOf<Employee>]
    var editingWeekEvents: IdentifiedArrayOf<EditingWeekEvent> = []
}

public let calendarWeekViewReducer: Reducer<CalendarWeekViewState, CalendarWeekViewAction, CalendarEnvironment> = .init { state, action, env in
	switch action {
	case .onPageSwipe(let isNext):
		let daysToAdd = isNext ? 7 : -7
		let newDate = state.selectedDate + daysToAdd.days
		state.selectedDate = newDate
	case .editStartTime(var startOfDayDate, let startDate, let eventId, let startingPointStartOfDay):
		let calId = CalendarEvent.ID.init(rawValue: eventId)
        var app = state.appointments[startingPointStartOfDay]?.remove(id: calId)
        let oldStartDate = app!.start_date
        let oldEndDate = app!.end_date
		app?.update(start: startDate)

		app.map {
			if state.appointments[startOfDayDate] == nil {
				state.appointments[startOfDayDate] = IdentifiedArrayOf<CalendarEvent>.init()
			}
			state.appointments[startOfDayDate]!.append($0)
		}
        
        let editingEvent = EditingWeekEvent(oldEvent: app!,
                                            oldStartDate: oldStartDate,
                                            oldEndDate: oldEndDate,
                                            newStartOfDayDate: startOfDayDate)
        state.editingWeekEvents.append(editingEvent)
        
        let appBuilder = AppointmentBuilder(calendarEvent: app!)
        
        return env.clientsAPI.updateAppointment(appointment: appBuilder)
            .catchToEffect()
            .map { response in CalendarWeekViewAction.editAppointmentResponse(response, id: app!.id) }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        

	case .editDuration(let startOfDayDate, let endDate, let eventId):
		let calId = CalendarEvent.ID.init(rawValue: eventId)
        
        var oldStartDate = state.appointments[startOfDayDate]?[id: calId]?.start_date
        var oldEndDate = state.appointments[startOfDayDate]?[id: calId]?.end_date
        
        state.appointments[startOfDayDate]?[id: calId]?.end_date = endDate
        
        guard let app = state.appointments[startOfDayDate]?[id: calId] else {
            return .none
        }
            
        let editingEvent = EditingWeekEvent(oldEvent: app,
                                            oldStartDate: oldStartDate!,
                                            oldEndDate: oldEndDate!,
                                            newStartOfDayDate: startOfDayDate)
        state.editingWeekEvents.append(editingEvent)
        
        let appBuilder = AppointmentBuilder(calendarEvent: app)
        return env.clientsAPI.updateAppointment(appointment: appBuilder)
            .catchToEffect()
            .map { response in CalendarWeekViewAction.editAppointmentResponse(response, id: app.id) }
            .receive(on: DispatchQueue.main)
            .eraseToEffect()
        
	case .addAppointment:
		break// handled in calendarContainerReducer
    case .editAppointment:
        break // handled in calendarContainerReducer
	case .addBookout(let startOfDayDate,
					 let startDate,
					 let durationMins):
		let chooseLocAndEmp = ChooseLocationAndEmployeeState(locations: state.locations,
															 employees: state.employees)
		state.addBookout = AddBookoutState(chooseLocAndEmp: chooseLocAndEmp,
										   start: startDate)
	case .onSelect(startOfDayDate: let startOfDayDate, eventId: let eventId):
		let calId = CalendarEvent.ID.init(rawValue: eventId)
		let event = state.appointments[startOfDayDate]?[id: calId]
		switch event {
		case .appointment(let app):
			state.appDetails = AppDetailsState(app: app)
		default:
			break
		}
    case .editAppointmentResponse(let response, let calendarEventId):
        switch response {
        case .success(let result):
            state.editingWeekEvents.remove(id: result)
        case .failure(let error):
            guard var editingEvent = state.editingWeekEvents.first(where: { $0.id == calendarEventId }) else { break }

            var app: CalendarEvent!
            app = state.appointments[editingEvent.newStartOfDayDate]?.remove(id: calendarEventId)
            
            let oldStartOfDayDate = editingEvent.oldStartDate.startOfDay
            
            app.update(startDate: editingEvent.oldStartDate, endDate: editingEvent.oldEndDate)
            if state.appointments[oldStartOfDayDate] == nil {
                state.appointments[oldStartOfDayDate] = IdentifiedArrayOf<CalendarEvent>.init()
            }
            state.appointments[oldStartOfDayDate]!.append(app)
            
            state.editingWeekEvents.removeAll(where: { $0.id == calendarEventId })
        }
	}
	return .none
}

public enum CalendarWeekViewAction {
	case onPageSwipe(isNext: Bool)
	case addAppointment(startOfDayDate: Date,
						startDate: Date,
						durationMins: Int)
    case editAppointment(_ appointment: Appointment)
    case editAppointmentResponse(Result<CalendarEvent.ID, RequestError>, id: CalendarEvent.ID)
	case addBookout(startOfDayDate: Date,
					startDate: Date,
					durationMins: Int)
	case editStartTime(startOfDayDate: Date,
					   startDate: Date,
					   eventId: Int,
					   startingPointStartOfDay: Date)
	case editDuration(startOfDayDate: Date,
					  endDate: Date,
					  eventId: Int)
	case onSelect(startOfDayDate: Date,
				  eventId: Int)
}
