import Model
import Foundation
import ComposableArchitecture
import SwiftDate
import Appointments
import JZCalendarWeekView
import CoreGraphics
import AppointmentDetails
import ToastAlert
import Util

public struct CalendarSectionViewReducer<Subsection: Identifiable & Equatable> {
	let reducer = Reducer<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>, CalendarEnvironment> { state, action, env in
		switch action {
        
		case .addAppointment:
			break //handled in calendarContainerReducer
		
		case .editSections(startDate: let startDate, startKeys: let startIndexes, dropKeys: let dropIndexes, eventId: let eventId):
			let calId = CalendarEvent.Id(rawValue: eventId)
            
            guard var app = state.appointments.appointments[startIndexes.location]?[startIndexes.subsection]?.remove(id: calId) else {
                break
            }
            
			let oldEvent = app
			
			app.update(start: startDate)
			app.locationId = dropIndexes.location
            
			var newSection: Either<Room.ID, Employee.ID>!
			if let roomId = dropIndexes.subsection as? Room.ID {
				app.roomId = roomId
				newSection = .left(roomId)
			} else if let empId = dropIndexes.subsection as? Employee.ID {
				app.employeeId = empId
				newSection = .right(empId)
			}
            
            var oldSection: Either<Room.ID, Employee.ID>!
            if let roomId = startIndexes.subsection as? Room.ID {
                oldSection = .left(roomId)
            } else  if let empId = startIndexes.subsection as? Employee.ID {
                oldSection = .right(empId)
            }
            
			if state.appointments.appointments[dropIndexes.location] == nil {
				state.appointments.appointments[dropIndexes.location] = [:]
			}

            state.appointments.appointments[dropIndexes.location]?[dropIndexes.subsection]?.append(app)
			
			let editingEvent = EditingEvent(oldEvent: oldEvent,
											newLocation: dropIndexes.location,
											newSection: newSection,
                                            oldSection: oldSection,
											newStartDate: startDate)
			state.editingSectionEvents.append(editingEvent)
            print(state.editingSectionEvents)
            
			
			let appBuilder = AppointmentBuilder(calendarEvent: app)
			
            return env.clientsAPI.updateAppointment(appointment: appBuilder)
                .catchToEffect()
                .map { response in SubsectionCalendarAction.appointmentEdited(response, id: app.id) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
			
		case .onPageSwipe(isNext: let isNext):
			
			let daysToAdd = isNext ? 1 : -1
			let newDate = state.selectedDate + daysToAdd.days
			state.selectedDate = newDate
			
		case .editDuration(let newEndDate, let startIndexes, let eventId):
			let calId = CalendarEvent.Id(rawValue: eventId)
			let oldDateO = state.appointments.appointments[startIndexes.location]?[startIndexes.subsection]?[id: calId]?.end_date
			guard let oldDate = oldDateO else { return .none }
            guard let app = state.appointments.appointments[startIndexes.location]?[startIndexes.subsection]?[id: calId] else {
                return .none
            }
            
            let oldEvent = app
            var oldSection: Either<Room.ID, Employee.ID>!
            if let roomId = startIndexes.subsection as? Room.ID {
                oldSection = .left(roomId)
            } else  if let empId = startIndexes.subsection as? Employee.ID {
                oldSection = .right(empId)
            }
            
            state.appointments.appointments[startIndexes.location]?[startIndexes.subsection]?[id: calId]?.end_date = Date.concat(oldDate, newEndDate)
            
            let editingEvent = EditingEvent(oldEvent: app,
                                            newLocation: oldEvent.locationId,
                                            newSection: oldSection,
                                            oldSection: oldSection,
                                            newStartDate: oldEvent.start_date)
            state.editingSectionEvents.append(editingEvent)

			let appointmentBuilder = AppointmentBuilder(calendarEvent: app)
            
            return env.clientsAPI.updateAppointment(appointment: appointmentBuilder)
                .receive(on: DispatchQueue.main)
                .catchToEffect()
                .map{ response in SubsectionCalendarAction.appointmentEdited(response, id: app.id) }
                .eraseToEffect()
			
		case .onSelect(let keys, let eventId):
			let (location, subsection) = keys
			let calId = CalendarEvent.Id(rawValue: eventId)
			let event = state.appointments.appointments[keys.location]?[keys.subsection]?[id: calId]
			switch event {
			case .appointment(let app):
				state.appDetails = AppDetailsState(app: app)
			default:
				break
			}
		case .addBookout(startDate: let startDxate, durationMins: let durationMins, dropKeys: let dropKeys):
			break
        case .appointmentEdited(let result, let calendarEventId):
            switch result {
            case .success(let placeholder):
				state.editingSectionEvents.remove(id: placeholder)
                state.editingSectionEvents.removeAll(where: { $0.id == calendarEventId })
                
                state.toast = ToastState(mode: .banner(.slide),
                                         type: .regular,
                                         title: Texts.appointmentModifiedSuccessfully)
                
                return Effect.timer(id: ToastTimerId(), every: 5, on: DispatchQueue.main)
                    .map { _ in SubsectionCalendarAction.dismissToast }
			case .failure(let error):
                guard let editingEvent = state.editingSectionEvents.first(where: { $0.id == calendarEventId }) else { break }
                var app: CalendarEvent!
                
                switch editingEvent.newSection {
                case .left(let roomId):
                    let subsectionId = roomId as! Subsection.ID
                    app = state.appointments.appointments[editingEvent.oldEvent.locationId]?[subsectionId]?.remove(id: editingEvent.id)
                case .right(let employeeId):
                    let subsectionId = employeeId as! Subsection.ID
                    app = state.appointments.appointments[editingEvent.oldEvent.locationId]?[subsectionId]?.remove(id: editingEvent.id)
                }
                
                app.update(startDate: editingEvent.oldEvent.start_date, endDate: editingEvent.oldEvent.end_date)
                app.locationId = editingEvent.oldEvent.locationId
                
                switch editingEvent.oldSection {
                case .left(let roomId):
                    let subsectionId = roomId as! Subsection.ID
                    state.appointments.appointments[editingEvent.oldEvent.locationId]?[subsectionId]?.append(app)
                case .right(let employeeId):
                    let subsectionId = employeeId as! Subsection.ID
                    state.appointments.appointments[editingEvent.oldEvent.locationId]?[subsectionId]?.append(app)
                }
                
                state.editingSectionEvents.removeAll(where: { $0.id == calendarEventId })
                
                state.toast = ToastState(mode: .banner(.slide),
                                         type: .regular,
                                         title: Texts.appointmentModifiedFailed)
                
                return Effect.timer(id: ToastTimerId(), every: 5, on: DispatchQueue.main)
                    .map { _ in SubsectionCalendarAction.dismissToast }
            }
        case .dismissToast:
            state.toast = nil
            return .cancel(id: ToastTimerId())
		}
		return .none
	}
	//	.debug(state: { return $0 }, action: (/SubsectionCalendarAction.editAppointment))
}
