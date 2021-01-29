import Model
import Foundation
import NonEmpty
import CasePaths
import Overture

public typealias Journey = [CalAppointment]

public extension Journey {
	var servicesString: String {
		self.compactMap { $0.service }
			.reduce("", +)
	}
}

let filterAppointments = with(CalendarEvent.appointment, curry(extract(case:from:)))

func calendarResponseToJourneys(date: Date, events: [CalendarEvent]) -> [Journey] {
	return with(events.compactMap(filterAppointments),
				with(date, curry(groupAndFilter(date:appointments:))))
}

func groupAndFilter(date: Date, appointments: [CalAppointment]) -> [Journey] {
	group(appointments: appointments)
		.first { $0.key.isInside(date: date, granularity: .day) }
		.map(\.value) ?? []
}

func group(appointments: [CalAppointment]) -> [Date: [Journey]] {
	
	struct JourneyKey: Hashable {
		let customerId: Client.ID
		let employeeId: Employee.ID
	}
	
	return Dictionary(grouping: appointments, by: { $0.start_date })
		.mapValues {
			Dictionary(grouping: $0, by: {
				return JourneyKey(customerId: $0.customerId, employeeId: $0.employeeId)
			}).map(\.value)
		}
}
