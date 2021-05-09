import Model
import Foundation
import ComposableArchitecture
import SwiftDate
import Appointments
import JZCalendarWeekView
import CoreGraphics

public struct AppointmentsByReducer<Subsection: Identifiable & Equatable> {
	let reducer = Reducer<CalendarSectionViewState<Subsection>, SubsectionCalendarAction<Subsection>, CalendarEnvironment> { state, action, env in
		switch action {
		case .addAppointment:
			break //handled in calendarContainerReducer
		case .editSections(startDate: let startDate, startKeys: let startIndexes, dropKeys: let dropIndexes, eventId: let eventId):
			let calId = CalendarEvent.Id(rawValue: eventId)
            
            guard var app = state.appointments.appointments[state.selectedDate]?[startIndexes.location]?[startIndexes.subsection]?.remove(id: calId) else {
                break
            }
            
			app.update(start: startDate)
			app.locationId = dropIndexes.location
            
			if let roomId = dropIndexes.subsection as? Room.ID {
				app.roomId = roomId
			} else if let empId = dropIndexes.subsection as? Employee.ID {
				app.employeeId = empId
			}
            
			if state.appointments.appointments[state.selectedDate] == nil {
				state.appointments.appointments[state.selectedDate] = [:]
			}

            state.appointments.appointments[startDate]?[dropIndexes.location]?[dropIndexes.subsection]?.append(app)
            
            var appointmentBuilder: AppointmentBuilder?
            
            if let appointment = app.getAppointment() {
                appointmentBuilder = AppointmentBuilder(appointment: appointment)
            }
            
            if let bookout = app.getBookout() {
                appointmentBuilder = AppointmentBuilder(bookout: bookout)
            }
            
            guard let appointment = appointmentBuilder else {
                return .none
            }

            return env.clientsAPI.updateAppointment(appointment: appointment)
                .catchToEffect()
                .map(SubsectionCalendarAction.appointmentEdited)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
		case .onPageSwipe(isNext: let isNext):
			let daysToAdd = isNext ? 1 : -1
			let newDate = state.selectedDate + daysToAdd.days
			state.selectedDate = newDate
		case .editDuration(let newEndDate, let startIndexes, let eventId):
			let calId = CalendarEvent.Id(rawValue: eventId)
			let oldDateO = state.appointments.appointments[state.selectedDate]?[startIndexes.location]?[startIndexes.subsection]?[id: calId]?.end_date
			guard let oldDate = oldDateO else { return .none }
            
			state.appointments.appointments[state.selectedDate]?[startIndexes.location]?[startIndexes.subsection]?[id: calId]?.end_date = Date.concat(oldDate, newEndDate)
            
            guard let app = state.appointments.appointments[state.selectedDate]?[startIndexes.location]?[startIndexes.subsection]?[id: calId] else {
                return .none
            }

            var appointmentBuilder: AppointmentBuilder?

            if let appointment = app.getAppointment() {
                appointmentBuilder = AppointmentBuilder(appointment: appointment)
            }

            if let bookout = app.getBookout() {
                appointmentBuilder = AppointmentBuilder(bookout: bookout)
            }

            guard let appointment = appointmentBuilder else {
                return .none
            }
            
            return env.clientsAPI.updateAppointment(appointment: appointment )
                .receive(on: DispatchQueue.main)
                .catchToEffect()
                .map(SubsectionCalendarAction.appointmentEdited)
                .eraseToEffect()
		case .onSelect(let keys, let eventId):
			let (location, subsection) = keys
			let calId = CalendarEvent.Id(rawValue: eventId)
			let event = state.appointments.appointments[state.selectedDate]?[keys.location]?[keys.subsection]?[id: calId]
			switch event {
			case .appointment(let app):
				state.appDetails = AppDetailsState(app: app)
			default:
				break
			}
		case .addBookout(startDate: let startDxate, durationMins: let durationMins, dropKeys: let dropKeys):
			break
        case .appointmentEdited(let result):
            switch result {
            case .success(let placeholder):
                print(placeholder)
            default:
                break
            }
			
		case .viewDidAppear(let sectionWidth):
			print("sectionWidth: \(sectionWidth)")
			state.sectionWidth = sectionWidth
		}
		return .none
	}
	//	.debug(state: { return $0 }, action: (/SubsectionCalendarAction.editAppointment))
}
