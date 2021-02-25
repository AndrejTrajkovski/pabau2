import Model
import Foundation
import NonEmpty
import CasePaths
import Overture
import Appointments

public typealias Journey = [Appointment]

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

func groupAndFilter(date: Date, appointments: [Appointment]) -> [Journey] {
	journeyGroup(appointments: appointments)
		.first { $0.key.isInside(date: date, granularity: .day) }
		.map(\.value) ?? []
}

struct JourneyKey: Hashable {
	let customerId: Client.ID
	let employeeId: Employee.ID
}

func journeyGroup(appointments: [Appointment]) -> [Date: [Journey]] {
	return Dictionary(grouping: appointments, by: { $0.start_date })
		.mapValues {
			Dictionary(grouping: $0, by: {
				return JourneyKey(customerId: $0.customer_id, employeeId: $0.employeeId)
			}).map(\.value)
		}
}
